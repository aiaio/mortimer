class PermissionsController < ApplicationController

  before_filter :login_required, :find_user

  def create 
    params[:permission][:admin_user_id]  = current_user.id
    params[:permission][:admin_password] = session[:pwd]
    if @user.permissions.create(params[:permission])
      render :partial => "permissions/menu"
    else
      render :text => "There was an error creating the permission.", :status => 500
    end 

    rescue ActiveRecord::RecordNotFound 
      render :text => "Not found."
  end

  def destroy
    @user.permissions.find(params[:id]).destroy
    @user.reload
    render :partial => "permissions/menu"
  end

  protected

    def find_user
      @user = User.find(params[:user_id])
    end  

end
