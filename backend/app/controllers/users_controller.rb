class UsersController < ApplicationController
    def create
        user = User.create(user_params)
        
        if user.valid?
            render json: UserSerializer.new(user).to_serialized_json
        else 
            render json: {error: true, message: "Invalid username or password. Please try again."}
        end
    end
    
    private
     
    def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
