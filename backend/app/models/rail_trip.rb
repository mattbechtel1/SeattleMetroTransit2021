class RailTrip < ApplicationRecord
  acts_as_copy_target
  belongs_to :rail_route
  belongs_to :rail_calendar, optional: true

  def self.next_station_trains(station)
    RailStoptime.where(station_code: station)
  end

end
