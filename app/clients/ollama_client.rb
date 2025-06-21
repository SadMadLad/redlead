class OllamaClient < ApplicationClient
  delegate :chat, :complete, :model, to: :@client

  MODELS = {
    ollama_gemma: "gemma3:4b",
    ollama_gemma_sm: "gemma3:1b",

    ollama_llama: "llama3.1:latest",
    ollama_llama_sm: "llama3.2:1b",

    ollama_deepseek_sm: "deepseek-r1:1.5b",
    ollama_deepseek_lg: "deepseek-r1:7b",

    ollama_qwen: "qwen2.5vl:3b",
    ollama_qwen_lg: "qwen2.5:7b",

    ollama_moondream_sm: "moondream:latest",

    ollama_granite: "granite-embedding:278m",
    ollama_mxbai: "mxbai-embed-large:latest",
    ollama_nomic: "nomic-embed-text:latest"
  }.with_indifferent_access.freeze

  def initialize(completion_model: :ollama_llama_sm, embedding_model: :ollama_nomic, options: {})
    @client = Langchain::LLM::Ollama.new(
      url: ENV["OLLAMA_API_BASE"],
      default_options: {
        embedding_model: embedding_models[embedding_model],
        completion_model: completion_models[completion_model],
        chat_model: completion_models[completion_model],
        stream: true,
        options:
      }
    )
  end

  def embed(...)
    @client.embed(...).embeddings
  end

  %i[completion_model embedding_model chat_model].each do |key|
    define_method(key) { @client.defaults[key] }
  end

  class << self
    def models
      MODELS
    end

    def completion_models
      models.slice(
        :ollama_gemma_sm, :ollama_qwen, :ollama_gemma, :ollama_llama, :ollama_qwen_lg, :ollama_deepseek_lg,
        :ollama_deepseek_sm, :ollama_moondream_sm, :ollama_llama_sm
      )
    end

    def embedding_models
      models.slice(
        :ollama_gemma_sm, :ollama_qwen, :ollama_gemma, :ollama_llama, :ollama_qwen_lg, :ollama_deepseek_lg,
        :ollama_deepseek_sm, :ollama_moondream_sm, :ollama_llama_sm, :ollama_mxbai, :ollama_nomic, :ollama_granite
      )
    end

    def tools_models
      models.slice(:ollama_llama, :ollama_qwen_lg, :ollama_llama_sm)
    end

    def vision_models
      models.slice(:ollama_qwen, :ollama_gemma, :ollama_moondream_sm)
    end
  end

  private
    %i[models completion_models embedding_models tools_models vision_models].each do |method_name|
      define_method(method_name) { self.class.public_send(method_name) }
    end
end
