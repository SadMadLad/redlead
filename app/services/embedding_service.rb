class EmbeddingService < ApplicationService
  required_params :record

  BATCH_SIZE = 128

  def call
    set_embedding_models
    @client = OllamaClient.new

    if single_record?
      process_single_record
    else
      process_multiple_records
    end
  end

  private
    def set_embedding_models
      @embedding_models ||= (@record.is_a?(Array) ? @record.first : @record).embedding_models
      @embedding_models = Array(@embedding_models).uniq
    end

    def single_record?
      !@record.respond_to?(:length)
    end

    def process_single_record
      embedding_data = @embedding_models.each_slice(2).map do |embedding_models|
        embedding_data = Parallel.map(embedding_models, in_threads: embedding_models.length) do |embedding_model|
          embedding = @client.embed(model: OllamaClient.models[embedding_model], text: @record.public_send(embeddable)).first

          { embeddable: @record, embedding:, embedding_model: }
        end
      end

      Embedding.create embedding_data
    end

    def process_multiple_records
      embedding_data = enumerator.map do |records|
        @embedding_models.each_slice(2).map do |embedding_models|
          Parallel.map(embedding_models, in_threads: embedding_models.length) do |embedding_model|
            embeddings = @client.embed(model: OllamaClient.models[embedding_model], text: records.map(&:"#{embeddable}"))

            records.zip(embeddings).map { |record, embedding| { embeddable: record, embedding:, embedding_model: } }
          end
        end
      end

      Embedding.create embedding_data.flatten
    end

    def embeddable
      @embeddable ||= (@record.is_a?(Array) ? @record.first : @record).embeddable
    end

    def enumerator
      if @record.is_a?(Array)
        @record.each_slice(BATCH_SIZE)
      else
        @record.find_in_batches(batch_size: BATCH_SIZE)
      end
    end
end
