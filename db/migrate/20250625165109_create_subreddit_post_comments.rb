class CreateSubredditPostComments < ActiveRecord::Migration[8.0]
  def change
    create_table :subreddit_post_comments do |t|
      t.belongs_to :subreddit_post, null: true, foreign_key: true
      t.belongs_to :parent, null: true, foreign_key: { to_table: :subreddit_post_comments }

      t.integer :depth
      t.integer :downs
      t.integer :likes
      t.integer :score
      t.integer :ups

      t.bigint :created_utc

      t.string :author
      t.string :author_fullname
      t.string :display_id
      t.string :link_id
      t.string :name
      t.string :parent_display_id
      t.string :subreddit_name
      t.string :subreddit_str_id
      t.string :subreddit_name_prefixed

      t.text :body
      t.text :body_html
      t.text :permalink

      t.index :name, unique: true

      t.timestamps
    end
  end
end
