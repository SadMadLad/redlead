module RedditQueries
  extend ActiveSupport::Concern

  included do
    scope :latest, ->(starting_duration = 1.hour) { where(created_at: starting_duration.ago..DateTime.current) }
    scope :latest_by_reddit, ->(starting_duration = 1.hour) { where(created_utc: starting_duration.ago.to_i..DateTime.current.to_i) }
  end
end
