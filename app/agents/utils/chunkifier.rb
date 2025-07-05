module Utils
  class Chunkifier
    def initialize(messages:, slice_size: 50, truncation: nil, google: false)
      @messages = messages
      @slice_size = slice_size
      @truncation = truncation || {}
      @google = google
    end

    def call
      @messages.each_slice(@slice_size).map do |chunked_messages|
        if @truncation.present?
          chunked_messages.map { |message| truncate_message(message) }
        else
          chunked_messages
        end
      end.map { |messages_chunk| process_messages_chunk(messages_chunk) }
    end

    class << self
      def call(...)
        new(...).call
      end
    end

    private
      def truncate_message(message)
        message_access = message.with_indifferent_access
        @truncation.each do |attribute, value|
          if message_access.key?(attribute) && message_access[attribute].respond_to?(:truncate)
            message_access[attribute] = message_access[attribute].truncate(value)
          end
        end
        message
      end

      def process_messages_chunk(chunk)
        processed_yaml = chunk.to_yaml.squeeze(" ").squeeze("\n")
        if google_provider?
          { role: "user", parts: { text: processed_yaml } }
        else
          { role: "user", content: processed_yaml }
        end
      end

      def google_provider?
        @google == true
      end
  end
end
