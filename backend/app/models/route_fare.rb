class RouteFare < ApplicationRecord
  acts_as_copy_target
  belongs_to :fare_attribute
  belongs_to :route
end
