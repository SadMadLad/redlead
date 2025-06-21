class CreateSubreddits < ActiveRecord::Migration[8.0]
  def change
    create_table :subreddits do |t|
      t.integer :subscribers

      t.string :display_name
      t.string :display_id
      t.string :name
      t.string :title
      t.string :url, null: false

      t.text :description
      t.text :description_html

      t.index :url, unique: true

      t.timestamps
    end
  end
end
