class RenameShapeDistranceTraveledToShapeDistanceTraveled < ActiveRecord::Migration[6.0]
  def change
    rename_column :stoptimes, :shape_distrance_traveled, :shape_distance_traveled
  end
end
