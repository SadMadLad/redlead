module Utils
  module RedditParser
    REQUIRED_SUBREDDIT_FIELDS = %w[description description_html display_name id name subscribers title url created_utc].freeze
    REQUIRED_SUBREDDIT_POST_FIELDS = %w[num_comments score ups upvote_ratio author author_fullname id domain name
    permalink url subreddit_name_prefixed subreddit subreddit_id subreddit_title selftext selftext_html title created_utc].freeze
    REQUIRED_SUBREDDIT_POST_COMMENDS_FIELDS = %w[author author_fullname body body_html created_utc depth downs id likes link_id name parent_id
    permalink score subreddit subreddit_id ups subreddit_name_prefixed].freeze

    private
      def parse_subreddits(response, _code)
        parsed_response = JSON.parse(response)
        after = parsed_response.dig("data", "after")
        children = parsed_response.dig("data", "children")
        children = children.pluck("data").map do |child|
          child = child.slice(*REQUIRED_SUBREDDIT_FIELDS)
          child.transform_keys { |key| key == "id" ? "display_id" : key }
        end

        [ children, after ]
      end

      def parse_subreddit(response, _code)
        parsed_response = JSON.parse(response)
        parsed_data = parsed_response.dig("data").slice(*REQUIRED_SUBREDDIT_FIELDS)

        parsed_data.transform_keys { |key| key == "id" ? "display_id" : key }
      end

      def parse_subreddit_posts(response, code)
        case code
        when 429
          :too_many_requests
        when 451
          :unavailable
        else
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

      def parse_subreddit_post_comments(response, code)
        case code
        when 404
          :not_found
        when 429
          :too_many_requests
        else
          comments = []
          unprocessed_comments = JSON.parse(response).last&.dig("data", "children")

          return [] if unprocessed_comments.blank?

          unprocessed_comments = unprocessed_comments.pluck("data")

          unprocessed_comments.each do |unprocessed_comment|
            next if unprocessed_comment["author"].in?([ "AutoModerator", "[deleted]" ])

            comments << unprocessed_comment.slice(*REQUIRED_SUBREDDIT_POST_COMMENDS_FIELDS)
            replies = unprocessed_comment.dig("replies")

            if replies.present?
              chained_comments = replies.dig("data", "children")
              unprocessed_comments.concat(chained_comments.pluck("data").flatten)
            end
          end

          comments = comments.map do |comment|
            comment.transform_keys do |key|
              case key
              when "id" then "display_id"
              when "parent_id" then "parent_display_id"
              when "subreddit_id" then "subreddit_str_id"
              when "subreddit" then "subreddit_name"
              else key
              end
            end
          end

          comments
        end
      end
  end
end
