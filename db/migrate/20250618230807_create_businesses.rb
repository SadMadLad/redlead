class CreateBusinesses < ActiveRecord::Migration[8.0]
  def change
    create_table :businesses do |t|
      t.string :title, null: false
      t.string :website_url

      t.text :description, null: false
      t.text :intelligent_scraped_summary

      t.timestamps
    end
  end
end
