class RemoveUrlFromFavorites < ActiveRecord::Migration[6.0]
  def change

    remove_column :favorites, :url, :string
  end
end
