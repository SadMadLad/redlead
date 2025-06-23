class ScrapeSubredditPostsJob < ApplicationJob
  def perform(subreddit_id, continue_upto: 3, embed: false, async: false)
    subreddit = Subreddit.find(subreddit_id)
    after = nil

    0.upto(continue_upto) do
      subreddit_posts, after = RedditClient[:subreddit_posts, subreddit, after:]
      subreddit_posts = subreddit.subreddit_posts.create subreddit_posts
      subreddit_posts = subreddit_posts.filter(&:valid?)

      subreddit_posts.each_slice(20) do |posts|
        SubredditPost.embed(posts, async:)
      end if embed

      break if after.blank?
    end
  end
end
