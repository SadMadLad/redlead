class ScrapeSubreddiPostCommentsJob < ApplicationJob
  def perform(subreddit_post_id, embed: false, async: false)
    subreddit_post = SubredditPost.find(subreddit_post_id)
  end
end
