Subreddit.where.not(id: SubredditPost.pluck(:subreddit_id).uniq).each do |subreddit|
  ScrapeSubredditPostsJob.new.perform(subreddit.id)
end

SubredditPost.left_outer_joins(:embeddings).where(embeddings: { id: nil }).find_each(batch_size: 1) do |subreddit_post|
  subreddit_post.embed(async: false)
end

unscrapable_post = SubredditPost.find_by(display_id: "1lhizpw")
subreddit_posts = SubredditPost.left_outer_joins(:subreddit_post_comments).where(subreddit_post_comments: { id: nil })
subreddit_posts.each do |subreddit_post|
  ScrapeSubredditPostCommentsJob.new.perform(subreddit_post.id, embed: true, async: false)
rescue URI::InvalidURIError
  puts "\n\n\nURI::InvalidURIError\n\n\n"
end


replies = SubredditPostComment.where.not(depth: 0)

replies.each do |reply|
  parent = SubredditPostComment.find_by(name: reply.parent_display_id)

  reply.update(parent_id: parent.id) if parent.present?
end

def dumb_stuff
  subreddit_post = SubredditPost.joins(:embeddings).random.first
  nn = subreddit_post.nearest_neighbors.pluck(:title)

  [ subreddit_post.title ] + nn
end

def dumb_stuff_two(query)
  SubredditPost.recommendations(query).pluck(:title)
end
