class CreateStoptimes < ActiveRecord::Migration[6.0]
  def change
    create_table :stoptimes do |t|
      t.references :trip, null: false, foreign_key: {on_delete: :cascade}
      t.time :arrival_time
      t.time :departure_time
      t.references :stop, null: false, foreign_key: {on_delete: :cascade}
      t.integer :sequence
      t.string :headsign
      t.integer :pickup_type
      t.integer :dropoff_type
      t.float :shape_distrance_traveled
      t.integer :timepoint
    end
  end
end
