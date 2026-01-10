class RailTrip < ApplicationRecord
  acts_as_copy_target
  belongs_to :rail_route
  belongs_to :rail_calendar, optional: true
  has_many :rail_stoptimes

  def trip_code
    self.rail_trip_id
  end

end
