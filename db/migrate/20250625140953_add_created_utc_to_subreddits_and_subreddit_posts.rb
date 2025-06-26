class AddCreatedUtcToSubredditsAndSubredditPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :subreddits, :created_utc, :bigint, if_not_exists: true
    add_column :subreddit_posts, :created_utc, :bigint, if_not_exists: true
  end
end
