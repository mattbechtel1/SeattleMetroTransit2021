class FavoritesController < ApplicationController

    def create
        newFav = Favorite.create(favorite_params)
        if newFav.valid?
            render json: newFav
        else
            render json: {error: true, message: "This favorite is already in your list."}
        end
    end

    def index
        favorites = Favorite.all
        render json: favorites
    end

    def update
        favorite = Favorite.find(params[:id])
        result = favorite.update(favorite_params)
        if result
            render json: favorite
        else
            render json: {error: true, message: 'Something went wrong.'}
        end
    end

    def destroy
        favorite = Favorite.find(params[:id])
        favorite.destroy
        render json: favorite
    end


    private

    def favorite_params
        params.require(:favorite).permit(:user_id, :description, :permanent_desc, :lookup, :transit_type)
    end
end
