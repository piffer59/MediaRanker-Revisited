class UsersController < ApplicationController
  before_action :require_login, only: [:index, :show]

  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]

    user = User.find_by(uid: auth_hash[:uid], provider: "github")

    if user
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.email}"
    else
      user = User.build_from_github(auth_hash)

      if user.save
        flash[:result_text] = "Logged in as new user"
      else
        flash[:message] = "Could not create new user account: #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id

    return redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out!"

    redirect_to root_path
  end
end
