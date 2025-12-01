class AddRailCalendarReferenceToRailTrips < ActiveRecord::Migration[7.2]
  def change
    add_reference :rail_trips, :rail_calendar, index: true, type: :string
  end
end
