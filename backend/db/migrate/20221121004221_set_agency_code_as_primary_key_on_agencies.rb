class SetAgencyCodeAsPrimaryKeyOnAgencies < ActiveRecord::Migration[6.0]
  def up
    execute "ALTER TABLE agencies ADD PRIMARY KEY (agency_code);"
  end

  def down
    execute "ALTER TABLE agencies DROP CONSTRAINT agencies_pkey;"
  end
end
