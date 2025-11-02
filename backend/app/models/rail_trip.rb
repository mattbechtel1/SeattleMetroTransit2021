class RailTrip < ApplicationRecord
  acts_as_copy_target
  belongs_to :rail_route
end
