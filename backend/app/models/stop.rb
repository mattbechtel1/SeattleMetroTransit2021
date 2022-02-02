class Stop < ApplicationRecord
  acts_as_copy_target
  belongs_to :stop, optional: true
  has_many :stoptimes
  has_many :trips, through: :stoptimes
  has_many :routes, through: :trips

  alias_attribute :StopName, :name

  def BusPredictions
    now = Time.new
    formatted_now = now.strftime("%H:%M:%S")
    hour = now.hour + 1
    hour_from_now = (now + 3600).strftime("#{hour.to_s}:%M:%S")
    self.stoptimes.where(
      "departure_time >= ? AND departure_time < ?", formatted_now, hour_from_now
    )
  end

end
