class ApplicationAgent
  class ModelNotFoundError < StandardError; end
  class ProviderNotFoundError < StandardError; end

  AVAILABLE_MODELS = {
    google: {
      gemini_20_flash: {
        features: %i[ chat completion tools ],
        name: "gemini-2.0-flash"
      },
      gemini_20_flash_image: {
        features: %i[ chat completion image_generation ],
        name: "gemini-2.0-flash-preview-image-generation"
      },
      gemini_15_flash: {
        features: %i[ chat completion ],
        name: "gemini-1.5-flash"
      },
      gemini_15_flash_8b: {
        features: %i[ chat completion ],
        name: "gemini-1.5-flash-8b"
      },
      text_embedding_004: {
        features: %i[ embedding ],
        name: "text-embedding-004"
      },
      gemma_3_27b: {
        features: %i[ chat completion tools ],
        name: "gemma-3-27b-it"
      },
      gemma_3_12b: {
        features: %i[ chat completion tools ],
        name: "gemma-3-27b-it"
      },
      gemma_3n: {
        features: %i[ chat completion tools ],
        name: "gemma-3n-e4b-it"
      }
    },
    informer: {
      gte: {
        features: %i[ embedding ],
        name: "Supabase/gte-small"
      },
      jina: {
        features: %i[ rerank ],
        name: "jinaai/jina-reranker-v1-turbo-en"
      }
    },
    ollama: {
      deepseek_sm: {
        features: %i[ chat complation embedding ],
        name: "deepseek-r1:1.5b"
      },
      deepseek_lg: {
        features: %i[ chat completion embedding ],
        name: "deepseek-r1:7b"
      },
      gemma_sm: {
        features: %i[ chat completion ],
        name: "gemma3:1b"
      },
      gemma: {
        features: %i[ chat completion image_analysis ],
        name: "gemma3:4b"
      },
      granite: {
        features: %i[ embedding ],
        name: "granite-embedding:278m"
      },
      llama_31: {
        features: %i[ chat completion embedding tools ],
        name: "llama3.1:latest"
      },
      llama_32_sm: {
        features: %i[ chat completion embedding tools ],
        name: "llama3.2:1b"
      },
      llava_phi3: {
        features: %i[ chat completion embedding image_analysis ],
        name: "llava-phi3:3.8b"
      },
      moondream: {
        features: %i[ chat completion embedding image_analysis ],
        name: "moondream:latest"
      },
      mxbai: {
        features: %i[ embedding ],
        name: "mxbai-embed-large:latest"
      },
      nomic: {
        features: %i[ embedding ],
        name: "nomic-embed-text:latest"
      },
      qwen: {
        features: %i[ chat completion embedding image_analysis ],
        name: "qwen2.5vl:3b"
      },
      qwen_lg: {
        features: %i[ chat completion embedding tools ],
        name: "qwen2.5:7b"
      }
    }
  }.freeze

  def initialize(quick = false, ...)
    set_instances
    return if quick

    initialize_model_by_provider(...)
  end

  def initialize_model_by_provider(...)
    send(:"initialize_model_by_#{@provider}", ...)
  end

  def chat_by_provider(...)
    raise StandardError, "The model #{@model[:name]} cannot chat" unless can_chat?
    send(:"chat_by_#{@provider}", ...)
  end

  def complete_by_provider(...)
    raise StandardError, "The model #{@model[:name]} cannot do completions" unless can_do_completion?
    send(:"complete_by_#{@provider}", ...)
  end

  def embed_by_provider(...)
    raise StandardError, "The model #{@model[:name]} cannot produce embeddings" unless can_embed?
    send(:"embed_by_#{@provider}", ...)
  end

  def rerank_by_provider(...)
    raise StandardError, "The model #{@model[:name]} cannot rerank" unless can_rerank?
    send(:"rerank_by_#{@provider}", ...)
  end

  %i[ chat complete embed rerank ].each { |method| alias_method method, :"#{method}_by_provider" }

  def quick_chat(provider_name, model_key, ...)
    quick_setup(provider_name, model_key)
    chat(...)
  end

  def quick_complete(provider_name, model_key, ...)
    quick_setup(provider_name, model_key)
    complete(...)
  end

  def quick_embed(provider_name, model_key, ...)
    quick_setup(provider_name, model_key)
    embed(...)
  end

  def quick_rerank(provider_name, model_key, ...)
    quick_setup(provider_name, model_key)
    rerank(...)
  end

  protected

    ### Helpers

    def quick_setup(provider_name, model_key)
      @provider = provider_name
      @model_key = model_key
      @model = AVAILABLE_MODELS.dig(@provider, @model_key)

      initialize_model_by_provider
    end

    def set_instances
      %i[ @provider @model @model_key @prompt @google_schema ].each do |instance|
        instance_variable_set instance, self.class.instance_variable_get(instance)
      end
    end

    def prepare_options(**options)
      default_options = {
        embedding_model:  (@model[:name] if can_embed?),
        completion_model: (@model[:name] if can_do_completion?),
        chat_model:       (@model[:name] if can_chat?)
      }.compact_blank

      { default_options: }.deep_merge(options)
    end

    def informer_model(embedding: true)
      Object.const_get @model_key.to_s.upcase.prepend(embedding ? "INFORMER_" : "RANKING_").to_sym
    end

    def google_message(text, role: "user")
      { role:, parts: { text: } }
    end

    ### Setup

    def initialize_model_by_ollama(**options)
      options = prepare_options(**options.merge(url: ENV["OLLAMA_API_BASE"]))

      @ollama_llm = Langchain::LLM::Ollama.new(**options)
    end

    def initialize_model_by_informer; end

    def initialize_model_by_google(**options)
      options = prepare_options(**options.merge(api_key: ENV["GOOGLE_GEMINI_API_KEY"]))

      @google_llm = Langchain::LLM::GoogleGemini.new(**options)
    end

    ### Embeddings

    def embed_by_ollama(*sentences, **options)
      @ollama_llm.embed(text: sentences, **options).embeddings
    end

    def embed_by_informer(*sentences, **options)
      informer_model.(sentences)
    end

    def embed_by_google(*sentences, **options)
      # As of now, gemini was embedding one text at a time. Maybe an issue in the way I am using the API?
      @google_llm.embed(text: sentences.first, **options).embeddings
    end

    ### Completions

    def complete_by_ollama(...)
      @ollama_llm.complete(...).completion
    end

    def complete_by_google(*message_prompts, **opts)
      raise ArgumentError, "A single prompt must be provided" if message_prompts.blank?

      opts[:generation_config] = @google_schema if @google_schema.present?

      messages = message_prompts
      messages = messages.map { |message_prompt| google_message(message_prompt) } unless opts[:already_processed] == true
      messages.unshift google_message(@prompt) if @prompt.present?

      @google_llm.chat(messages:, **opts).chat_completion
    end

    ### Chats

    def chat_by_ollama(...)
      @ollama_llm.chat(...)
    end

    def chat_by_google(...)
      @google_llm.chat(...)
    end

    ### Rerank

    def rerank_by_informer(...)
      informer_model(embedding: false).(...)
    end

    ### Abilities

    {
      can_embed?: :embedding,
      can_do_image_analysis?: :image_analysis,
      can_perform_functions?: :tools,
      can_chat?: :chat,
      can_do_completion?: :completion,
      can_rerank?: :rerank,
      can_generate_images?: :image_generation
    }.each { |method_name, ability| define_method(method_name) { able?(ability) } }

    def able?(ability)
      @model[:features].include?(ability)
    end

    class << self
      def example(example_text)
        raise StandardError, "Prompt must be declared first" if @prompt.nil?

        @prompt = [
          @prompt,
          example_text
        ].join("\n")
      end

      def model(model_name)
        return @model if @model.present?

        @model_key = model_name.to_sym
        @model = AVAILABLE_MODELS.dig(@provider, @model_key)

        raise StandardError, "Provider must be set first" if @provider.blank?
        raise StandardError, "Model not found" if @model.blank?
      end

      def google_schema(**provided_google_schema)
        return @google_schema if @google_schema.present?

        generation_config = {}
        generation_config[:responseMimeType] = "application/json"
        generation_config[:responseSchema] = provided_google_schema

        @google_schema = generation_config
      end

      def prompt(text)
        @prompt ||= text
      end

      def provider(provider_name)
        @provider = provider_name.to_sym

        raise ArgumentError, "Provider not available" unless @provider.in?(AVAILABLE_MODELS.keys)
      end

      def embedding_models
        @embedding_models ||= map_models_with_prefix filter_models_by_feature(:embedding)
      end

      def filter_models_by_feature(feature)
        AVAILABLE_MODELS.transform_values do |models|
          models.select { |_, v| v[:features].include?(feature) }
        end
      end

      def map_models_with_prefix(models_hash)
        models_hash.flat_map do |provider, models|
          models.map { |key, val| [ :"#{provider}_#{key}", val[:name] ] }
        end.to_h
      end

      ### Quick Helpers

      def quick_chat(...) = new(true).quick_chat(...)
      def quick_complete(...) = new(true).quick_complete(...)
      def quick_embed(...) = new(true).quick_embed(...)
      def quick_rerank(...) = new(true).quick_rerank(...)
    end
end
