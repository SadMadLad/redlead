class AddScrapedAtToSubreddits < ActiveRecord::Migration[8.0]
  def change
    add_column :subreddits, :scraped_at, :datetime
  end
end
