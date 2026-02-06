class RailTrip < ApplicationRecord
  acts_as_copy_target
  belongs_to :rail_route
  belongs_to :rail_calendar, optional: true
  has_many :rail_stoptimes
  has_many :stations, through: :rail_stoptimes

  def self.by_route_and_direction route_short_name, direction_id
    RailTrip.joins(:rail_route).where(rail_routes: {"short_name": route_short_name}, direction_id: direction_id)
  end

  def trip_code
    self.rail_trip_id
  end

end
