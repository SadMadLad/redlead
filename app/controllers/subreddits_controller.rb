class SubredditsController < ApplicationController
  before_action :set_subreddit, only: %i[ show ]

  def index
    @pagy, @subreddits = pagy(Subreddit.all)
  end

  def show
    @subreddit_posts = @subreddit.posts
  end

  private
    def set_subreddit
      @subreddit = Subreddit.find(params[:id])
    end
end
