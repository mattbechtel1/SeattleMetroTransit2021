class AddTypeAndLookupToFavorites < ActiveRecord::Migration[6.0]
  def change
    add_column :favorites, :type, :string
    add_column :favorites, :lookup, :string
  end
end
