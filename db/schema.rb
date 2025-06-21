# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_19_195017) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "businesses", force: :cascade do |t|
    t.string "title", null: false
    t.string "website_url"
    t.text "description", null: false
    t.text "intelligent_scraped_summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "embeddings", force: :cascade do |t|
    t.string "embeddable_type", null: false
    t.bigint "embeddable_id", null: false
    t.string "embedding_model", null: false
    t.vector "embedding", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["embeddable_type", "embeddable_id"], name: "index_embeddings_on_embeddable"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "subreddits", force: :cascade do |t|
    t.integer "subscribers"
    t.string "display_name"
    t.string "display_id"
    t.string "name"
    t.string "title"
    t.string "url", null: false
    t.text "description"
    t.text "description_html"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "index_subreddits_on_url", unique: true
  end
end
