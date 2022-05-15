class AddCalendarReferenceToTrips < ActiveRecord::Migration[6.0]
  def change
    add_reference :trips, :calendar, index: true
  end
end
