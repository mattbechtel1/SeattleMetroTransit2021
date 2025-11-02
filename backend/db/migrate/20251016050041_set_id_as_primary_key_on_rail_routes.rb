class SetIdAsPrimaryKeyOnRailRoutes < ActiveRecord::Migration[7.2]
  def up
    execute "ALTER TABLE rail_routes ADD PRIMARY KEY (id);"
  end

  def down
    execute "ALTER TABLE rail_routes DROP CONSTRAINT rail_routes_pkey;"
  end
end
