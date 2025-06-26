class Subreddit < ApplicationRecord
  include Embeddable

  set_embeddable :embeddable_data
  set_embedding_models :informer_gte, :informer_nomic

  has_many :subreddit_posts, dependent: :nullify
  has_many :subreddit_post_comments, through: :subreddit_posts

  alias_method :posts, :subreddit_posts
  alias_method :comments, :subreddit_post_comments

  validates_presence_of *%i[subscribers display_name display_id title url description description_html name]

  validates :subscribers, comparison: { greater_than_or_equal_to: 0 }
  validates :url, uniqueness: true

  def embeddable_data
    return @prompt if @prompt

    @prompt = <<~XML
      <subreddit-name>#{url}</subreddit-name>
      <subreddit-title>#{title}</subreddit-title>
    XML

    @prompt = @prompt.squish
  end

  def refresh(async: false)
    if async
      RefreshSubredditJob.perform_later(id)
    else
      RefreshSubredditJob.new.perform(id)
    end
  end
end
