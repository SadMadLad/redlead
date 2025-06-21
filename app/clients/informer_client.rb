class InformerClient < ApplicationClient
  RANKING_MODLES = {
    informer_mxbai: "mixedbread-ai/mxbai-rerank-base-v1"
  }.with_indifferent_access.freeze

  EMBEDDING_MODELS = {
    informer_gte: "Supabase/gte-small",
    informer_mxbai: "mixedbread-ai/mxbai-embed-large-v1",
    informer_nomic: "nomic-ai/nomic-embed-text-v1"
  }.with_indifferent_access.freeze

  MODELS_DETAILS = {
    "Supabase/gte-small" => Informers.pipeline("embedding", "Supabase/gte-small"),
    "mixedbread-ai/mxbai-embed-large-v1" => Informers.pipeline("embedding", "mixedbread-ai/mxbai-embed-large-v1"),
    "nomic-ai/nomic-embed-text-v1" => Informers.pipeline("embedding", "nomic-ai/nomic-embed-text-v1")
}.with_indifferent_access.freeze

  def initialize
    @client = Informers
  end

  def embed(embedding_model, sentences)
    sentences = Array(sentences) unless sentences.is_a?(Array)
    model = @client.pipeline("embedding", models[embedding_model])

    model.(sentences)
  end

  def [](model_key)
    MODELS_DETAILS[EMBEDDING_MODELS[model_key]]
  end

  class << self
    def models
      EMBEDDING_MODELS
    end

    def ranking_models
      RANKING_MODELS
    end
  end

  private
    %i[ models ranking_models ].each do |method_name|
      define_method(method_name) { self.class.public_send(method_name) }
    end
end
