class FavoritesController < ApplicationController

    def create
        newFav = Favorite.create(favoriteParams)
        render json: newFav
    end

    def index
        favorites = Favorite.all
        render json: favorites
    end


    private

    def favoriteParams
        params.require(:favorite).permit(:user_id, :url, :description, :lookup, :transit_type)
    end
end
