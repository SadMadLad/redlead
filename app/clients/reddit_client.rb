class RedditClient < ApplicationClient
  include Utils::RedditParser

  BASE_URL = "https://www.reddit.com"

  def initialize
    @client = Faraday.new(
      url: BASE_URL,
      headers: { "Content-Type" => "application/json" }
    )
  end

  def subreddits(**params)
    response = @client.get("/subreddits.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddits response.body
  end

  def subreddit(subreddit_url, **params)
    subreddit_url = subreddit_url.url if subreddit_url.is_a?(Subreddit)

    response = @client.get("#{subreddit_url}/about.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddit response.body
  end

  def subreddit_posts(subreddit_url, listing_type: "new", limit: 100, **params)
    subreddit_url = subreddit_url.url if subreddit_url.is_a?(Subreddit)
    params = params.merge(limit:)

    response = @client.get("#{subreddit_url}/#{listing_type}.json") do |req|
      req.params = req.params.merge(params)
    end

    parse_subreddit_posts response.body
  end

  class << self
    def [](method_name, ...)
      new.public_send(method_name, ...)
    end
  end
end
