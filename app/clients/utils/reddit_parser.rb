module Utils
  module RedditParser
    REQUIRED_SUBREDDIT_FIELDS = %w[description description_html display_name id name subscribers title url].freeze

    private
      def parse_subreddits(response)
        parsed_response = JSON.parse(response)
        after = parsed_response.dig("data", "after")
        children = parsed_response.dig("data", "children")
        children = children.pluck("data").map do |child|
          child = child.slice(*REQUIRED_SUBREDDIT_FIELDS)
          child.transform_keys { |key| key == "id" ? "display_id" : key }
        end

        [ children, after ]
      end
  end
end
