class InformerClient < ApplicationClient
  RANKING_MODLES = {
    informer_mxbai: "mixedbread-ai/mxbai-rerank-base-v1"
  }.with_indifferent_access.freeze

  EMBEDDING_MODELS = {
    informer_gte: "Supabase/gte-small",
    informer_mxbai: "mixedbread-ai/mxbai-embed-large-v1",
    informer_nomic: "nomic-ai/nomic-embed-text-v1"
  }.with_indifferent_access.freeze

  def embed(embedding_model, sentences)
    sentences = Array(sentences) unless sentences.is_a?(Array)
    pipeline_model = model(embedding_model)

    pipeline_model.(sentences)
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
        # when :informer_mxbai
        #   INFORMER_MXBAI
        # when :informer_nomic
        #   INFORMER_NOMIC
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
end
