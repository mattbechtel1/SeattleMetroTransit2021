class SetIdAsPrimaryKeyOnStations < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER TABLE stations ADD PRIMARY KEY (id);"
  end

  def down
    execute "ALTER TABLE stations DROP CONSTRAINT stations_pkey;"
  end
end
