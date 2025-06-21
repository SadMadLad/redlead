class Embedding < ApplicationRecord
  PROVIDERS = %i[ ollama informer ].freeze

  has_neighbors :embedding

  belongs_to :embeddable, polymorphic: true

  validates :embedding_model, presence: true, uniqueness: { scope: %i[ embeddable_id embeddable_type ] }

  enum :embedding_model, OllamaClient.embedding_models.merge(InformerClient.models)

  class << self
    PROVIDERS.each do |provider|
      define_method(:"#{provider}_embedded") { Embedding.where("embedding_model LIKE ?", "#{provider}%") }
    end

    Embedding.embedding_models.keys.each do |embedding_model|
      define_method(embedding_model) { Embedding.where(embedding_model:) }
    end
  end

  PROVIDERS.each do |provider|
    define_method(:"#{provider}?") { embedding_model.to_sym.start_with?(provider.to_s) }
  end
end
