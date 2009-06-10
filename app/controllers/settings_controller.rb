# Remembers which password groups are open / closed.
class SettingsController < ApplicationController
  
  # Make sure that the create command can only be executed via xhr.
  verify :xhr => true, :only => :show, :add_flash => {:notice => "Sorry, Charile :)"}, :redirect_to => "/" 

  # If the session is expired, handle that in the controller.
  skip_before_filter :expire_session

  skip_before_filter :verify_authenticity_token
  
  def create
    if session_expired?
      render :text => login_url, :status => 401
    else
      store_open_groups
    end
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 401
  end

  private

  def store_open_groups
    group = Group.find(params[:id]) 
    if group.self_and_ancestors.any? {|g| current_user.groups.include?(g)}
      session[:open_groups] ||= {}
      session[:open_groups][group.id] = (params[:open] == 'true') ? true : nil
    end
    render :nothing => true, :status => 200
  end

end
