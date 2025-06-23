class RefreshSubredditJob < ApplicationJob
  def perform(subreddit_id)
    subreddit = Subreddit.find(subreddit_id)
    new_subreddit_data = RedditClient[:subreddit, subreddit]
    subreddit.assign_attributes(new_subreddit_data)

    subreddit.save
  end
end
