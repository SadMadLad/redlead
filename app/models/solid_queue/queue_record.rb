module SolidQueue
  class QueueRecord < ApplicationRecord
    self.abstract_class = true

    connects_to database: { writing: :queue, reading: :queue }
  end
end
