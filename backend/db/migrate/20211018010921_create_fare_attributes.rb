class CreateFareAttributes < ActiveRecord::Migration[6.0]
  def change
    create_table :fare_attributes do |t|
      t.references :agency, null: false, foreign_key: true
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
