module Embeddable
  extend ActiveSupport::Concern

  included do
    class_attribute :embeddable, :embedding_models
    has_many :embeddings, as: :embeddable, dependent: :destroy
  end

  class_methods do
    def embeddings(model: nil)
      Embedding.where **{ embeddable_type: name.to_s, model: }.compact
    end

    def embed(records, async: true, embedding_models: self.embedding_models || %i[informer_gte])
      raise ArgumentError, "Please set the embeddable first" if embeddable.blank?

      embedding_models = Array(embedding_models)
      use_informer = embedding_models.all? { |embedding_model| embedding_model.start_with?("informer") }

      service = use_informer ? InformerService : EmbeddingService

      if async
        CallServiceJob.perform_later(service, record: records, embedding_models:)
      else
        service.call(record: records, embedding_models:)
      end
    end

    def embed_all(...)
      embed(all, ...)
    end

    def set_embeddable(name)
      self.embeddable = name.to_sym
    end

    def set_embedding_models(*embedding_models)
      embedding_models = Array(embedding_models)
      self.embedding_models = embedding_models.uniq.map(&:to_sym)
    end

    def embedding_by_model(embedding_model, query)
      if embedding_model.start_with?("informer")
        InformerClient.new.embed(embedding_model, query)
      else
        OllamaClient.new(embedding_model:).embed(text: query)
      end.first
    end

    # Finding neighbors of a record
    def nearest_neighbors(record, embedding_model: :informer_gte, distance: "cosine")
      vector = record.embeddings.find_by(embedding_model:)
      return [] if vector.blank?

      neighbors(vector.embedding, embedding_model, distance).excluding(record)
    end

    # Finding neighbors based on the query embedding
    def recommendations(query, embedding_model: :informer_gte, distance: "cosine")
      query_embedding = embedding_by_model(embedding_model, query)

      neighbors(query_embedding, embedding_model, distance)
    end

    # Attempt at hybrid querying
    def multi_query_recommendations(queries, embedding_model: :informer_gte, distance: "cosine")
      queries.map { |query| recommendations(query, embedding_model:, distance:) }
    end

    # Helper method to find the results based on the query
    def neighbors(query_embedding, embedding_model, distance, limit: 10)
      neighbor_ids = embeddings
        .public_send(embedding_model)
        .nearest_neighbors(:embedding, query_embedding, distance:)
        .limit(limit)
        .pluck(:embeddable_id)

      where(id: neighbor_ids)
        .order(
          Arel.sql("array_position(ARRAY[#{neighbor_ids.join(',')}]::int[], id)")
        )
    end
  end

  def embed(async: true, embedding_models: self.embedding_models || %i[informer_gte])
    raise ArgumentError, "Please set the embeddable first" if self.class.embeddable.blank?

    embedding_models = Array(embedding_models)
    use_informer = embedding_models.all? { |embedding_model| embedding_model.start_with?("informer") }

    if use_informer
      if async
        CallServiceJob.perform_later(InformerService, record: self, embedding_models:)
      else
        InformerService.call(record: self, embedding_models:)
      end
    else
      if async
        CallServiceJob.perform_later(EmbeddingService, record: self, embedding_models:)
      else
        EmbeddingService.call(record: self, embedding_models:)
      end
    end
  end

  def nearest_neighbors(...)
    self.class.nearest_neighbors(self, ...)
  end
end
