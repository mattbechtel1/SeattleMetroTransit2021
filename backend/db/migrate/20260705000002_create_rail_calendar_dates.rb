class CreateRailCalendarDates < ActiveRecord::Migration[8.0]
  def change
    create_table :rail_calendar_dates do |t|
      t.string :service_id, null: false
      t.integer :date, null: false
      t.integer :exception_type, null: false
    end
    add_index :rail_calendar_dates, [:service_id, :date], unique: true
    add_index :rail_calendar_dates, :date
  end
end
