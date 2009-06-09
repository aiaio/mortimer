class UserPasswordsController < ApplicationController

  before_filter :find_user

  def edit
  end

  def update
    if !params[:user][:password].blank? && @user.update_attributes(password_params)
      flash[:notice] = "Password successfully changed."
      redirect_to login_url 
    else
      flash.now[:notice] = "Password not updated."
      render :action => :edit
    end
  end

  private

  def password_params
    {:old_password => session[:pwd], 
     :password     => params[:user][:password], 
     :password_confirmation => params[:user][:password_confirmation]}
  end

  def find_user
    @user = current_user
  end

end
