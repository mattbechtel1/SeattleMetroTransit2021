class RailStoptime < ApplicationRecord
  belongs_to :rail_trip
  belongs_to :station


  def self.trains_next_hour
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
    RailStoptime.where(
      "departure_time >= ? AND departure_time < ?", formatted_now, hour_from_now
    ).order(:departure_time)
  end
end
