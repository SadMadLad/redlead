class ScrapeSubredditsJob < ApplicationJob
  def perform(continue_upto: 30, embed: false, async: false)
    after = nil
    reddit_client = RedditClient.new

    0.upto(continue_upto) do
      subreddits, after = reddit_client.subreddits(after:)

      subreddits = Subreddit.create subreddits
      subreddits = subreddits.filter(&:valid?)

      Subreddit.embed if embed

      break if after.blank?
    end
  end
end
