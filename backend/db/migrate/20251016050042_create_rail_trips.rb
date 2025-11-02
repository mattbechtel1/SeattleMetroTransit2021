class CreateRailTrips < ActiveRecord::Migration[7.2]
  def change
    create_table :rail_trips, id: false do |t|
      t.references :rail_route, null: false, foreign_key: {on_delete: :cascade}, type: :string
      t.string :short_name
      t.string :rail_trip_id, primary_key: true
      t.string :headsign
      t.integer :direction_id

      t.timestamps
    end
  end
end
