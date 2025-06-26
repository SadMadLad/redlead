class ScrapeSubredditPostCommentsJob < ApplicationJob
  def perform(subreddit_post_id, embed: false, async: false)
    subreddit_post = SubredditPost.find(subreddit_post_id)

    comments = RedditClient[:subreddit_post_comments, subreddit_post]

    if comments == :too_many_requests
      puts "Too many requests. Sleeping for 3.5 minutes"

      sleep 3.5.minutes
    elsif comments == :not_found
      puts "Did not find the subreddit. Moving on"
    else
      created_comments = []

      parent_comments = comments.filter{ |comment| comment["parent_display_id"].start_with?("t1") }
      reply_comments = parent_comments.excluding(parent_comments)

      parent_comments.each do |parent_comment|
        comment = subreddit_post.comments.create(**parent_comment)
        created_comments << comment if comment.valid?
      end

      reply_comments.each do |reply_comment|
        parent_comment = subreddit_post.comments.find_by(name: reply_comment.parent_display_id)
        comment = subreddit_post.comments.create(**parent_comment.merge("parent_id" => parent_comment.id))
        created_comments << comment if comment.present? && comment.valid?
      end

      SubredditPostComment.embed(created_comments, async:) if embed
    end
  end
end
