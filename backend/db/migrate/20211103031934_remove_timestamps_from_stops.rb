class RemoveTimestampsFromStops < ActiveRecord::Migration[6.0]
  def change
    remove_column :stops, :created_at, :string
    remove_column :stops, :updated_at, :string
  end
end
