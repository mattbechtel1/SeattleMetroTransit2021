class Stoptime < ApplicationRecord
  extend AssistantUtils
  acts_as_copy_target
  belongs_to :trip
  belongs_to :stop
  has_one :route, through: :trip
  has_one :calendar, through: :trip

  def trip_id_string
    self.trip.id.to_s
  end
  alias TripID trip_id_string

  def stop_name
    self.stop.StopName
  end
  alias StopName stop_name

  def stop_id 
    self.stop.id
  end
  alias StopID stop_id

  def direction_id_string
    self.trip.direction_id.to_s
  end
  alias DirectionNum direction_id_string

  def route_short_name
    self.trip.route.short_name
  end
  alias RouteID route_short_name

  def direction_text
    self.trip.directional_text + " to " + self.trip.headsign
  end
  alias DirectionText direction_text

  def real_departure_time
    real_departure_time = self.departure_time
    if self.departure_time[0].to_i == 2 && self.departure_time[1].to_i > 3
      real_departure_time[0] = "0"
      real_departure_time[1] = (self.departure_time[1].to_i - 4).to_s
    end
    real_departure_time
  end

  def minutes_to_bus    
    ((self.real_departure_time.to_time - Time.now) / 60).floor()
  end
  alias Minutes minutes_to_bus

  def self.buses_next_hour
    # Need to add late night logic here
    now = Time.new
    if now.hour < 23 && now.hour > 3
      date = Date.today
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = (now + 3600).strftime("%H:%M:%S")
    elsif now.hour === 23
      date = Date.today
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = "24:" + now.strftime("%M:%S")
    else
      date = Date.yesterday
      formatted_now = (now.hour + 24).to_s + now.strftime(":%M:%S")
      hour_from_now = (now.hour + 25).to_s + now.strftime(":%M:%S")
    end
    Stoptime.where(
      "departure_time >= ? AND departure_time < ?", formatted_now, hour_from_now
    ).joins(trip: :calendar).where("calendars.start_date <= ? AND calendars.end_date >= ? AND calendars.#{adj_day_of_week} = 'true'", date.strftime("%Y%m%d"), date.strftime("%Y%m%d")
    ).order(:departure_time)
  end

  def self.buses_today day
    now = Time.new
    if now.hour < 23 && now.hour > 3
      date = Date.today
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = (now + 3600).strftime("%H:%M:%S")
    elsif now.hour === 23
      date = Date.today
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = "24:" + now.strftime("%M:%S")
    else
      date = Date.yesterday
      formatted_now = (now.hour + 24).to_s + now.strftime(":%M:%S")
      hour_from_now = (now.hour + 25).to_s + now.strftime(":%M:%S")
    end
    Stoptime.joins(trip: :calendar
    ).where("calendars.start_date <= ? AND calendars.end_date >= ? AND calendars.#{day} = 'true'", date.strftime("%Y%m%d"), date.strftime("%Y%m%d")
    ).order(:departure_time)
  end

end
