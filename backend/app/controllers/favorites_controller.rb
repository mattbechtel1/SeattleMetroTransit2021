class FavoritesController < ApplicationController

    def create
        newFav = Favorite.create(favoriteParams)
        render json: newFav
    end


    private

    def favoriteParams
        params.require(:favorite).permit(:user_id, :url, :description)
    end
end
