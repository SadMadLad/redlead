class ScrapeSubredditPostsJob < ApplicationJob
  def perform(subreddit_id, continue_upto: 3, embed: false, async: false)
    subreddit = Subreddit.find(subreddit_id)
    after = nil

    0.upto(continue_upto) do
      case response = RedditClient[:subreddit_posts, subreddit, after:]
      when :too_many_requests
        puts "Too many requests sent. Starting to sleep for 3 minutes. Subreddit Id: #{subreddit_id}"
        continue_upto += 1

        sleep 3.minutes
      when :unavailable
        SolidQueue::ExecutionLog.create(
          args: { subreddit_id:, continue_upto:, embed:, async: },
          job_class: self.class.name,
          description: "Too many requests made or legal issue. Potentially blocked as well."
        )
        break
      else
        subreddit_posts, after = response
        subreddit_posts = subreddit.subreddit_posts.create subreddit_posts
        subreddit_posts = subreddit_posts.filter(&:valid?)

        SubredditPost.embed(subreddit_posts, async:) if embed
      end
    end
  end
end
