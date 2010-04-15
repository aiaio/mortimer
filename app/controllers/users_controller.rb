class UsersController < ApplicationController

  # Only admins can access this controller.
  before_filter :admin_required
  
  # Get the user before these actions. 
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :toggle_admin, :reset_password, :edit, :update]
  
  # Display an index of all active users.
  def index
    @users = User.index
  end

  # Create a new user. 
  def new
    @user = User.new
  end

  # See before filters to code.
  def edit
  end

  def update
    params[:user][:old_password] = session[:pwd]
    if @user.update_attributes(params[:user])
      # If the user changes passwords, log out.
      if !params[:user][:password].blank?
        flash[:notice] = "Password successfully changed."
        redirect_to login_url 
      else
        flash[:notice] = "User successfully updated."
        redirect_to edit_user_url(@user)
      end
    else
      render :action => :edit
    end
  end
 
  def create
    @user = User.new(params[:user])
    @user.save if @user && @user.valid?
    success = @user && @user.valid?

    if success && @user.errors.empty?
      redirect_to users_path
      flash[:notice] = "User successfully created!"
    else
      flash[:notice]  = "There was an error setting up that account:"
      render :action => 'new'
    end
  end

  # Grant/Revoke admin status for the given user.
  def toggle_admin
    if @user.is_admin?
      @user.revoke_admin
    else
      @user.grant_admin(current_user, session[:pwd])
    end
    redirect_to edit_user_path(@user)
  end

  # Reset a user's password. This action can only be performed by admins.
  def reset_password
    new_password = @user.reset_password(current_user, session[:pwd])
    if new_password
      flash[:notice] = "New password for #{@user.login}: #{new_password}"
    else
      flash[:notice] = "Couldn't reset the user's password."
    end
    redirect_to edit_user_path(@user)
  end 

  def destroy 
    @user.destroy
    redirect_to users_path
  end
  
end
