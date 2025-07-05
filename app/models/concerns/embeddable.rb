module Embeddable
  extend ActiveSupport::Concern

  included do
    class_attribute :embeddable, :embedding_models
    has_many :embeddings, as: :embeddable, dependent: :destroy
  end

  class_methods do
    def embeddings(**args)
      Embedding.where({ embeddable_type: name.to_s, **args })
    end

    def embed
      raise ArgumentError, "Please set the embeddable first" if embeddable.blank?

      Embedding.create all.map { |record| QuickEmbeddingAgent.call(record) }.flatten
    end

    def set_embeddable(name)
      self.embeddable = name.to_sym
    end

    def set_embedding_models(*embedding_models)
      embedding_models = Array(embedding_models)
      self.embedding_models = embedding_models.uniq.map(&:to_sym)
    end

    def nearest_neighbors(record, embedding_model: :informer_gte, distance: "cosine", limit: 10)
      vector = record.embeddings.find_by(embedding_model:)
      return [] if vector.blank?

      neighbors(vector.embedding, embedding_model, distance, limit:).excluding(record)
    end

    def recommendations(query, embedding_model: :informer_gte, distance: "cosine", limit: 10)
      query_embedding = ApplicationAgent.quick_embed(*QuickEmbeddingAgent.lookup(embedding_model), query)

      neighbors(query_embedding, embedding_model, distance, limit:)
    end

    def multi_query_recommendations(queries, embedding_model: :informer_gte, distance: "cosine", limit: 10)
      queries.map { |query| recommendations(query, embedding_model:, distance:, limit: 10) }
    end

    def neighbors(query_embedding, embedding_model = :informer_gte, distance = "cosine", limit: 10, ordered: true)
      neighbors_ids = embeddings
        .public_send(embedding_model)
        .nearest_neighbors(:embedding, query_embedding, distance:)
        .limit(limit)
        .pluck(:embeddable_id)

      return self.where(id: neighbors_ids) unless ordered

      where(id: neighbors_ids).order(Arel.sql("array_position(ARRAY[#{neighbors_ids.join(',')}]::int[], id)"))
    end

    alias_method :embed_all, :embed
  end

  def embed
    raise ArgumentError, "Please set the embeddable first" if self.class.embeddable.blank?

    embeddings_data = QuickEmbeddingAgent.call(self)
    self.embeddings.create(embeddings_data.flatten)
  end

  def nearest_neighbors(...)
    self.class.nearest_neighbors(self, ...)
  end
end
