class Trip < ApplicationRecord
  acts_as_copy_target
  belongs_to :route
  belongs_to :fare_attribute
  belongs_to :agency
  belongs_to :calendar
  has_many :stoptimes
  has_many :stops, through: :stoptimes

  alias_attribute :TripHeadsign, :headsign
  alias_attribute :TripDirectionText, :directional_text
  alias_attribute :StopTimes, :stoptimes


  def self.by_route_and_direction route_short_name, direction_id
    if route_short_name.to_i < 1
      # If route is not a number, assume it is F LINE or f or F format
      route_short_name = route_short_name[0].upcase + " Line"
    end
    return Trip.joins(:route).where(routes: {"short_name": route_short_name}, direction_id: direction_id)
  end

  def directional_text
    ["Outbound", "Inbound"][self.direction_id]
  end

  def route_name
    self.route.short_name + " " + self.route.description
  end

  def stop_id
    self.stop.id
  end

  def self.get_stoptimes trip_ids
    Stoptime.joins(:trip).joins(:stop).joins(:route)
      .select("stoptimes.id AS id, stops.id AS stop_id, stops.name AS stop_name, trips.id AS trip_id, trips.headsign, routes.short_name AS route_short_name, CASE trips.direction_id WHEN 0 THEN 'Outbound' WHEN 1 THEN 'Inbound' ELSE 'unknown' END AS directional_text")
      .where(trip_id: trip_ids)
  end
end
