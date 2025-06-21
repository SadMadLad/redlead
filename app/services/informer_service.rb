class InformerService < ApplicationService
  required_params :record

  def call
    @client = InformerClient.new

    if single_record?
      process_single_record
    else
      process_multiple_record
    end
  end

  private
    def process_single_record
      embedding_data = Parallel.map(embedding_models, in_threads: embedding_models.length) do |embedding_model|
        embedding = @client.embed(embedding_model, @record.public_send(embeddable)).first

        { embeddable: @record, embedding:, embedding_model: }
      end

      Embedding.create embedding_data.flatten
    end

    def process_multiple_records
      embedding_data = enumerator.map do |records|
        Parallel.map(embedding_models, in_threads: embedding_models.length) do |embedding_model|
          embeddings = @client.embed(model: OllamaClient.models[embedding_model], text: records.map(&:"#{embeddable}"))

          records.zip(embeddings).map { |record, embedding| { embeddable: record, embedding:, embedding_model: } }
        end
      end

      Embedding.create embedding_data.flatten
    end

    def single_record?
      !@record.respond_to?(:length)
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

    def embedding_models
      return @embedding_models if @have_set_embedding_models

      @embedding_models ||= (@record.is_a?(Array) ? @record.first : @record).embedding_models
      @embedding_models = Array(@embedding_models).uniq
      @have_set_embedding_models = true
    end
end
