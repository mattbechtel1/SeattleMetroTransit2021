class RenameTypeToTransitType < ActiveRecord::Migration[6.0]
  def change
    rename_column :favorites, :type, :transit_type
  end
end
