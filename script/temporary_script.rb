Subreddit.where.not(id: SubredditPost.pluck(:subreddit_id).uniq).each do |subreddit|
  ScrapeSubredditPostsJob.new.perform(subreddit.id)
end

SubredditPost.left_outer_joins(:embeddings).where(embeddings: { id: nil }).find_each(batch_size: 1) do |subreddit_post|
  subreddit_post.embed(async: false)
end


def dumb_stuff
  subreddit_post = SubredditPost.joins(:embeddings).random.first
  nn = subreddit_post.nearest_neighbors.pluck(:title)

  [subreddit_post.title] + nn
end

def dumb_stuff_two(query)
  SubredditPost.recommendations(query).pluck(:title)
end
