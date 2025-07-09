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

ActiveRecord::Schema[8.0].define(version: 2025_06_28_214139) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "businesses", force: :cascade do |t|
    t.string "business_type"
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

  create_table "products", force: :cascade do |t|
    t.bigint "business_id", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_products_on_business_id"
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

  create_table "subreddit_post_comments", force: :cascade do |t|
    t.bigint "subreddit_post_id"
    t.bigint "parent_id"
    t.integer "depth"
    t.integer "downs"
    t.integer "likes"
    t.integer "score"
    t.integer "ups"
    t.bigint "created_utc"
    t.string "author"
    t.string "author_fullname"
    t.string "display_id"
    t.string "link_id"
    t.string "name"
    t.string "parent_display_id"
    t.string "subreddit_name"
    t.string "subreddit_str_id"
    t.string "subreddit_name_prefixed"
    t.text "body"
    t.text "body_html"
    t.text "permalink"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_subreddit_post_comments_on_name", unique: true
    t.index ["parent_id"], name: "index_subreddit_post_comments_on_parent_id"
    t.index ["subreddit_post_id"], name: "index_subreddit_post_comments_on_subreddit_post_id"
  end

  create_table "subreddit_posts", force: :cascade do |t|
    t.bigint "subreddit_id"
    t.integer "num_comments"
    t.integer "score"
    t.integer "ups"
    t.float "upvote_ratio"
    t.string "author"
    t.string "author_fullname"
    t.string "display_id"
    t.string "domain"
    t.string "name"
    t.string "permalink"
    t.string "url"
    t.string "subreddit_name"
    t.string "subreddit_name_prefixed"
    t.string "subreddit_str_id"
    t.text "selftext"
    t.text "selftext_html"
    t.text "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_utc"
    t.index ["name"], name: "index_subreddit_posts_on_name", unique: true
    t.index ["subreddit_id"], name: "index_subreddit_posts_on_subreddit_id"
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
    t.bigint "created_utc"
    t.datetime "scraped_at"
    t.index ["url"], name: "index_subreddits_on_url", unique: true
  end

  add_foreign_key "products", "businesses"
  add_foreign_key "subreddit_post_comments", "subreddit_post_comments", column: "parent_id"
  add_foreign_key "subreddit_post_comments", "subreddit_posts"
  add_foreign_key "subreddit_posts", "subreddits"
end
