class RedditClient < ApplicationClient
  include Utils::RedditParser

  BASE_URL = "https://www.reddit.com"
  USER_AGENTS = Mechanize::AGENT_ALIASES.except("Mechanize").values.freeze

  def initialize
    @client = Faraday.new(
      url: BASE_URL,
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "rails:localhost:3000 (by /u/Specific_Stable_4450)"
      }
    )
  end

  def subreddits(**params)
    response = @client.get("/subreddits.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddits response.body, response.status
  end

  def subreddit(subreddit_url, **params)
    subreddit_url = subreddit_url.url if subreddit_url.is_a?(Subreddit)
    subreddit_url = URI::DEFAULT_PARSER.escape(subreddit_url)

    response = @client.get("#{subreddit_url}/about.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddit response.body, response.status
  end

  def subreddit_posts(subreddit_url, listing_type: "new", limit: 100, **params)
    subreddit_url = subreddit_url.url if subreddit_url.is_a?(Subreddit)
    subreddit_url = URI::DEFAULT_PARSER.escape(subreddit_url)

    params = params.merge(limit:)

    response = @client.get("#{subreddit_url}/#{listing_type}.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddit_posts response.body, response.status
  end

  def subreddit_post_comments(subreddit_post_url, limit: 50, **params)
    subreddit_post_url = subreddit_post_url.permalink if subreddit_post_url.is_a?(SubredditPost)
    subreddit_post_url = URI::DEFAULT_PARSER.escape(subreddit_post_url)

    params = params.merge(limit:)

    response = @client.get("#{subreddit_post_url}.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddit_post_comments response.body, response.status
  end

  class << self
    def [](method_name, ...)
      new.public_send(method_name, ...)
    end
  end
end
