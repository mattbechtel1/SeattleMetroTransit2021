class CreateStations < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE TABLE stations AS TABLE stops WITH NO DATA;"
    execute "ALTER TABLE stations ALTER COLUMN id TYPE VARCHAR, ALTER COLUMN code TYPE VARCHAR, ALTER COLUMN stop_id TYPE VARCHAR, ALTER COLUMN zone_id TYPE VARCHAR;"
  end

  def down
    drop_table :stations
  end
end
