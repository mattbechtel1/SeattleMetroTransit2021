class AddFullStopNameToStations < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :full_stop_name, :string
  end
end
