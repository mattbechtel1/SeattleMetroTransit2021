class CreateFareAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :fare_attributes do |t|
      t.references :agency, null: false, type: :string, foreign_key: {on_delete: :cascade, primary_key: :agency_code}
      t.integer :fare_period_id
      t.float :price
      t.string :descriptions
      t.string :currency_type
      t.integer :payment_method
      t.integer :transfers
      t.integer :transfer_duration
    end
  end
end
