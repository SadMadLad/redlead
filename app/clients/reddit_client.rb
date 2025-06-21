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
end
