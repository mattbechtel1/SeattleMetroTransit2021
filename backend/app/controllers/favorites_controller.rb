class FavoritesController < ApplicationController

    def create
        newFav = Favorite.create(favoriteParams)
        # byebug
        render json: newFav
    end

    def index
        favorites = Favorite.all
        render json: favorites
    end


    private

    def favoriteParams
        params.require(:favorite).permit(:user_id, :url, :description)
    end
end
