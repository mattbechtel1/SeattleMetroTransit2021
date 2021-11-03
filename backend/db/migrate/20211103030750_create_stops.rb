class CreateStops < ActiveRecord::Migration[6.0]
  def change
    create_table :stops do |t|
      t.integer :code
      t.string :name
      t.string :description
      t.float :latitude
      t.float :longitude
      t.integer :zone_id
      t.string :url
      t.integer :location_type
      t.references :stop, null: true, foreign_key: {on_delete: :cascade}
      t.string :timezone

      t.timestamps
    end
  end
end
