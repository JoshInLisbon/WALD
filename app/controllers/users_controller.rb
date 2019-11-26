class UsersController < ApplicationController
  before_action :find_user_by_id, exclude: [:show]
  before_action :authorize_user, exclude: [:show]

  def show
    @user = User.includes(:bookings, :pets).find(params[:id])
  end

  def edit
  end

  def update
    @user.update(user_params)
    redirect_to user_path(@user)
  end

  private

  def find_user_by_id
    @user = User.find(params[:id])
  end

  def authorize_user
    authorize @user
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :description, :address, :email)
  end

end
