class SubredditPostsController < ApplicationController
  before_action :set_subreddit, :set_subreddit_post, only: %i[ show ]

  def show
    @subreddit_post_comments = @subreddit_post.comments.where(depth: 0).includes(replies: { replies: :replies })
  end

  private
    def set_subreddit
      @subreddit = Subreddit.find(params[:subreddit_id])
    end

    def set_subreddit_post
      @subreddit_post = @subreddit.posts.find(params[:id])
    end
end
