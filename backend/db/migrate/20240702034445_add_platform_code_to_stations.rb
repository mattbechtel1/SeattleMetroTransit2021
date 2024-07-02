class AddPlatformCodeToStations < ActiveRecord::Migration[6.0]
  def change
    add_column :stations, :platform_code, :string
  end
end
