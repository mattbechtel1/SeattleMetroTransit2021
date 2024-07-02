class AddBikesAllowedToTrips < ActiveRecord::Migration[6.0]
  def change
    add_column :trips, :bikes_allowed, :boolean
  end
end
