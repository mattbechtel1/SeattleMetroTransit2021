class AddWheelchairAccessibleToTrips < ActiveRecord::Migration[6.0]
  def change
    add_column :trips, :wheelchair_accessible, :boolean
  end
end
