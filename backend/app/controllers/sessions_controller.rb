class SessionsController < ApplicationController
  def new
  end

  def create
    byebug
    user = User.find_by(email: params[:email])
    return head(:forbidden) unless user.authenticate(params[:password])
    render json: UserSerializer.new(user).to_serialized_json
  end

  def destroy
    session.delete :email
  end

  private

  def session_params
    params.require(:sessions).permit(:email, :password)
  end
end
