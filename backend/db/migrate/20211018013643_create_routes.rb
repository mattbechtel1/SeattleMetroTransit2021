class CreateRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :routes do |t|
      t.references :agency, null: false, type: :string, foreign_key: {on_delete: :cascade, primary_key: :agency_code}
      t.string :short_name
      t.string :long_name
      t.string :description
      t.integer :route_type
      t.string :url
      t.string :color
      t.string :text_color
    end
  end
end
