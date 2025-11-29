class CreateRailStoptimes < ActiveRecord::Migration[7.2]
  def change
    create_table :rail_stoptimes do |t|
      t.references :rail_trip, null: false, foreign_key: {to_table: :rail_trips, primary_key: :rail_trip_id, on_delete: :cascade}, type: :string
      t.references :station, null: false, foreign_key: true, type: :string
      t.string :arrival_time
      t.string :departure_time
      t.integer :sequence
      t.integer :timepoint
      t.integer :departure_buffer
    end
  end
end
