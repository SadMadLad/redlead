class QuickEmbeddingAgent < ApplicationAgent
  EMBEDDINGS_LOOKUP = AVAILABLE_MODELS.flat_map do |provider, models|               # step into each provider block
    models
      .select { |_, meta| meta[:features].include?(:embedding) }
      .map { |model_key, _| [ :"#{provider}_#{model_key}", [ provider, model_key ] ] }
  end.to_h.with_indifferent_access

  class << self
    def embeddings_lookup
      EMBEDDINGS_LOOKUP
    end

    def lookup(model)
      embeddings_lookup[model]
    end

    def call(record)
      record.embedding_models.map do |embedding_model|
        args = [ *lookup(embedding_model), record.public_send(record.embeddable) ]
        {
          embedding: quick_embed(*args).first,
          embeddable: record,
          embedding_model:
        }
      end
    end
  end
end
