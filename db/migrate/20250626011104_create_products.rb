class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.belongs_to :business, null: false, foreign_key: true

      t.string :title

      t.text :description

      t.timestamps
    end
  end
end
