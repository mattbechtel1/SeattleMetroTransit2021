class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])

    if user
      if user.authenticate(params[:password])
          # user found and password authenticated
          render json: UserSerializer.new(user).to_serialized_json, status: :accepted
      else
          # user found, but bad password
          render json: { error: true, message: "Password does not match. Please try again." }, status: :unauthorized
      end
    else
      # user not found
      render json: { error: true, message: "Email not found." }, status: :unauthorized
    end
  end

  def destroy
    session.delete :email
  end

  private

  def session_params
    params.require(:sessions).permit(:email, :password)
  end
end
