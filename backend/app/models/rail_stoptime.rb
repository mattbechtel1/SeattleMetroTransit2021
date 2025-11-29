class RailStoptime < ApplicationRecord
  belongs_to :rail_trip
  belongs_to :station
end
