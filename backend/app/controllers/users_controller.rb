class UsersController < ApplicationController
    def create
        user = User.create(user_params)
        render json: user
    end

    # def show
    #     user = User.find(params[:id])
    #     render json: UserSerializer.new(user).to_serialized_json
    # end
    
    private
     
    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
