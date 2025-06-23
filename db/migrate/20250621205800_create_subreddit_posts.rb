class CreateSubredditPosts < ActiveRecord::Migration[8.0]
  def change
    create_table :subreddit_posts do |t|
      t.belongs_to :subreddit, null: true, foreign_key: true

      t.integer :num_comments
      t.integer :score
      t.integer :ups

      t.float :upvote_ratio

      t.string :author
      t.string :author_fullname
      t.string :display_id
      t.string :domain
      t.string :name
      t.string :permalink
      t.string :url
      t.string :subreddit_name
      t.string :subreddit_name_prefixed
      t.string :subreddit_str_id

      t.text :selftext
      t.text :selftext_html
      t.text :title

      t.index :name, unique: true

      t.timestamps
    end
  end
end
