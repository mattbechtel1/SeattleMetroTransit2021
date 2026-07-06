class RailStoptime < ApplicationRecord
  extend AssistantUtils
  include TimeRecord
  belongs_to :rail_trip
  belongs_to :station
  has_one :rail_calendar, through: :rail_trip


  def headsign
    self.rail_trip.headsign
  end

  def minutes_to_train
    ((self.real_departure_time - Time.now) / 60).floor()
  end

  def line_code
    self.rail_trip.rail_route.short_name
  end

  def self.trains_next_hour
    now = Time.zone.now
    date = service_date(now)
    if now.hour < 23 && now.hour > 3
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = (now + 3600).strftime("%H:%M:%S")
    elsif now.hour == 23
      formatted_now = now.strftime("%H:%M:%S")
      hour_from_now = "24:" + now.strftime("%M:%S")
    else
      formatted_now = (now.hour + 24).to_s + now.strftime(":%M:%S")
      hour_from_now = (now.hour + 25).to_s + now.strftime(":%M:%S")
    end
    eligible_calendar_ids = RailCalendar.service_ids_active_on(date)
    RailStoptime.where(
      "departure_time >= ? AND departure_time < ?", formatted_now, hour_from_now
    ).joins(:rail_trip).where(rail_trips: { rail_calendar_id: eligible_calendar_ids }
    ).order(:departure_time)
  end
end
