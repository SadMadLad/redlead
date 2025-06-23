module Utils
  module RedditParser
    REQUIRED_SUBREDDIT_FIELDS = %w[description description_html display_name id name subscribers title url].freeze
    REQUIRED_SUBREDDIT_POST_FIELDS = %w[num_comments score ups upvote_ratio author author_fullname id domain name
    permalink url subreddit_name_prefixed subreddit subreddit_id subreddit_title selftext selftext_html title].freeze

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

      def parse_subreddit(response)
        parsed_response = JSON.parse(response)
        parsed_data = parsed_response.dig("data").slice(*REQUIRED_SUBREDDIT_FIELDS)

        parsed_data.transform_keys { |key| key == "id" ? "display_id" : key }
      end

      def parse_subreddit_posts(response)
        parsed_response = JSON.parse(response)
        after = parsed_response.dig("data", "after")
        children = parsed_response.dig("data", "children")
        children = children.pluck("data").map do |child|
          child = child.slice(*REQUIRED_SUBREDDIT_POST_FIELDS)
          child.transform_keys do |key|
            case key
            when "id" then "display_id"
            when "subreddit_id" then "subreddit_str_id"
            when "subreddit" then "subreddit_name"
            else key
            end
          end
        end

        [ children, after ]
      end
  end
end
