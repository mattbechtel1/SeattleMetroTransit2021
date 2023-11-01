class CreateRailRoutes < ActiveRecord::Migration[6.0]
  def up
    execute "CREATE TABLE rail_routes AS TABLE routes WITH NO DATA;"
    execute "ALTER TABLE rail_routes ALTER COLUMN id TYPE VARCHAR;"
  end

  def down
    drop_table :rail_routes
  end
end
