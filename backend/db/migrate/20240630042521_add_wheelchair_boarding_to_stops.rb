class AddWheelchairBoardingToStops < ActiveRecord::Migration[6.0]
  def change
    add_column :stops, :wheelchair_boarding, :integer
  end
end
