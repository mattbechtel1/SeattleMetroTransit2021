class ChangeArrivalTimeAndDepartureTimeToBeStringsInStoptimes < ActiveRecord::Migration[6.0]
  def change
    change_column :stoptimes, :arrival_time, :string
    change_column :stoptimes, :departure_time, :string
  end
end
