class ChangeRouteFareReferenceToAllowNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :route_fares, :route_id, true
  end
end
