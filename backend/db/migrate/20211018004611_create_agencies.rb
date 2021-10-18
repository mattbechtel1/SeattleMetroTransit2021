class CreateAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :agencies do |t|
      t.string :name
      t.string :url
      t.string :timezone
      t.string :language
      t.string :phone
      t.string :fare_url
    end
  end
end
