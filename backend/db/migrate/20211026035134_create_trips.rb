class CreateTrips < ActiveRecord::Migration[6.0]
  def change
    create_table :trips do |t|
      t.references :route, null: false, foreign_key: true
      t.integer :service_id
      t.string :headsign
      t.string :short_name
      t.integer :direction_id
      t.integer :block_id
      t.integer :shape_id
      t.integer :peak_flag
      t.references :fare_attribute, null: false, foreign_key: true
    end
  end
end
