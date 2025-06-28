class InformerClient < ApplicationClient
  RANKING_MODLES = {
    informer_jina: "jinaai/jina-reranker-v1-turbo-en",
  }.with_indifferent_access.freeze

  EMBEDDING_MODELS = {
    informer_gte: "Supabase/gte-small"
  }.with_indifferent_access.freeze

  def embed(embedding_model, sentences)
    sentences = Array(sentences) unless sentences.is_a?(Array)
    pipeline_model = model(embedding_model)

    pipeline_model.(sentences)
  end

  def rerank(rerank_model, results, query)
    ranking_model(rerank_model).(query, results)
  end

  def [](model_key)
    model(model_key)
  end

  class << self
    def models
      EMBEDDING_MODELS
    end

    def ranking_models
      RANKING_MODELS
    end

    def model(key)
      case key.to_sym
      when :informer_gte
        INFORMER_GTE
      end
    end

    def ranking_model(key)
      case key.to_sym
      when :informer_jina
        RANKING_JINA
      end
    end
  end

  private
    %i[ models ranking_models ].each do |method_name|
      define_method(method_name) { self.class.public_send(method_name) }
    end

    def model(...)
      self.class.model(...)
    end

    def ranking_model(...)
      self.class.ranking_model(...)
    end
end
