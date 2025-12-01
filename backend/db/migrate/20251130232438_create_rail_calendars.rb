class CreateRailCalendars < ActiveRecord::Migration[7.2]
  def change
    create_table :rail_calendars, id: :string do |t|
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.boolean :sunday
      t.integer :start_date
      t.integer :end_date

    end
  end
end
