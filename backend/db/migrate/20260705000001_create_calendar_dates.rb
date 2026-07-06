class CreateCalendarDates < ActiveRecord::Migration[8.0]
  def change
    create_table :calendar_dates do |t|
      t.bigint :service_id, null: false
      t.integer :date, null: false
      t.integer :exception_type, null: false
    end
    add_index :calendar_dates, [:service_id, :date], unique: true
    add_index :calendar_dates, :date
  end
end
