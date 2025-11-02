class RemoveTimestampsFromRailTrips < ActiveRecord::Migration[7.2]
  def change
    remove_column :rail_trips, :created_at, :string
    remove_column :rail_trips, :updated_at, :string
  end
end
