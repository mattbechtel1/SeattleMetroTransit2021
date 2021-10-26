class CreateRouteFares < ActiveRecord::Migration[6.0]
  def change
    create_table :route_fares, id: false do |t|
      t.references :fare_attribute, null: false, foreign_key: {on_delete: :cascade}
      t.references :route, null: false, foreign_key: {on_delete: :cascade}
      t.integer :origin_id
      t.integer :destination_id
      t.integer :contains_id
    end
  end
end
