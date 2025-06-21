class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :random, -> { order("RANDOM()") }

  def as_open_struct
    OpenStruct.new as_json
  end
end
