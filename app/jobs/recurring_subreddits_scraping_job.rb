class RecurringSubredditsScrapingJob < ApplicationJob
  LogStruct = Struct.new(:scrappable)

  def perform(skip_comments: false)
    @unscraped_data = []

    Subreddit.order("scraped_at ASC NULLS FIRST").each do |subreddit|
      subreddit_posts, success = scrape_subreddit_posts(subreddit)

      next subreddit.update_column(:scraped_at, DateTime.now) if skip_comments

      if success
        subreddit_posts.each { |subreddit_post| scrape_subreddit_post_comments(subreddit_post) }

        subreddit.update_column(:scraped_at, DateTime.now)
      end
    end
  end

  private
    def scrape_unscraped_data
      while !@unscraped_data.empty?
        unscraped = @unscraped_data.shift.scrappable

        case unscraped.class
        when Subreddit
          scrape_subreddit_posts(unscraped)
          unscraped.update_column(:scraped_at, DateTime.now)
        when SubredditPost
          scrape_subreddit_post_comments(unscraped)
        end
      end
    end

    def scrape_subreddit_posts(subreddit)
      response, _ = RedditClient[:subreddit_posts, subreddit]

      if response == :too_many_requests
        log_unscraped(subreddit)

        [ now_sleep, false ]
      else
        subreddit_posts = subreddit.subreddit_posts.create(response)
        subreddit_posts = subreddit_posts.filter(&:valid?)
        subreddit_posts.each { |subreddit_post| subreddit_post.embed }

        [ subreddit_posts, true ]
      end
    end

    def scrape_subreddit_post_comments(subreddit_post)
      response = RedditClient[:subreddit_post_comments, subreddit_post]

      if response == :too_many_requests
        log_unscraped(subreddit_post)

        [ now_sleep, false ]
      else
        subreddit_post_comments = subreddit_post.subreddit_post_comments.create(response)
        subreddit_post_comments = subreddit_post_comments.filter(&:valid?)
        subreddit_post_comments.each { |comment| comment.embed }

        subreddit_post_comments
      end
    end

    def now_sleep
      puts "Too Many requests. Sleeping for 2.5 minutes"

      sleep 2.5.minutes
    end

    def log_unscraped(item)
      @unscraped_data << LogStruct.new(scrappable: item)
    end
end
