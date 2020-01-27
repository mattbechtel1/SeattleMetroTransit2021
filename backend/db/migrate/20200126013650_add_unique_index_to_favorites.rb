class AddUniqueIndexToFavorites < ActiveRecord::Migration[6.0]
  def change
    add_index :favorites, [:user_id, :lookup], unique: true
  end
end
