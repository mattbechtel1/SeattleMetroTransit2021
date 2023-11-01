class AddWheelchairBoardingToStations < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :wheelchair_boarding, :boolean
  end
end
