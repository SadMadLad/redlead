class SubredditPost < ApplicationRecord
  include Embeddable

  set_embeddable :prompt
  set_embedding_models :informer_gte

  belongs_to :subreddit, optional: true

  has_many :subreddit_post_comments, dependent: :nullify

  alias_method :comments, :subreddit_post_comments

  validates_presence_of :num_comments, :score, :ups, :upvote_ratio, :author, :author_fullname, :display_id, :domain, :name,
    :permalink, :url, :subreddit_name, :subreddit_name_prefixed, :subreddit_str_id, :title

  validates :num_comments, :score, :ups, comparison: { greater_than_or_equal_to: 0 }
  validates :name, uniqueness: true

  def prompt
    return @prompt if @prompt

    if title? && selftext?
      @prompt = <<~XML
        <title>#{title}</title>
        <description>#{selftext}</description>
      XML
      @prompt = @prompt.squish
    elsif title?
      @prompt = title
    else
      @prompt = selftext
    end
  end
end
