class SubredditPostComment < ApplicationRecord
  include Embeddable
  include RedditQueries

  set_embeddable :body
  set_embedding_models :informer_gte

  belongs_to :subreddit_post, optional: true
  belongs_to :parent, class_name: "SubredditPostComment", optional: true

  has_many :replies, class_name: "SubredditPostComment", foreign_key: "parent_id", dependent: :destroy

  # Attribute to store the ranking score temporarily
  attribute :ranking_score, :float

  validates_presence_of :body, :body_html, :permalink, :subreddit_name, :subreddit_str_id, :subreddit_name_prefixed, :author,
    :author_fullname, :display_id, :name, :created_utc

  validates :name, uniqueness: true
end
