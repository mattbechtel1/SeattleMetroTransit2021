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
    return Trip.joins(:route).where(routes: {"short_name": route_short_name}, direction_id: direction_id)
  end

  def directional_text
    ["Outbound", "Inbound"][self.direction_id]
  end

  def route_name
    self.route.short_name + " " + self.route.description
  end
end
