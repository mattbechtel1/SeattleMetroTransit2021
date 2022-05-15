class Stoptime < ApplicationRecord
  extend AssistantUtils
  acts_as_copy_target
  belongs_to :trip
  belongs_to :stop
  has_one :calendar, through: :trip

  alias_attribute :Minutes, :minutes_to_bus 
  alias_attribute :TripID, :trip_id_string
  alias_attribute :DirectionText, :direction_text
  alias_attribute :DirectionNum, :direction_id_string
  alias_attribute :RouteID, :route_short_name

  def trip_id_string
    self.trip.id.to_s
  end

  def direction_id_string
    self.trip.direction_id.to_s
  end

  def route_short_name
    self.trip.route.short_name
  end

  def direction_text
    ["Outbound", "Inbound"][self.trip.direction_id] + " to " + self.trip.headsign
  end

  def minutes_to_bus
    ((self.departure_time.to_time - Time.now) / 60).floor()
  end

  def self.buses_next_hour
    # Need to add late night logic here
    now = Time.new
    formatted_now = now.strftime("%H:%M:%S")
    hour_from_now = (now + 3600).strftime("%H:%M:%S")
    Stoptime.where(
      "departure_time >= ? AND departure_time < ?", formatted_now, hour_from_now
    ).joins(trip: :calendar).where(calendars: {day_of_week.to_sym => true})
  end
end
