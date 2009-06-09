# Remembers which password groups are open / closed.
class SettingsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  
  def create
    group = Group.find(params[:id]) 
    if group.self_and_ancestors.any? {|g| current_user.groups.include?(g)}
      session[:open_groups] ||= {}
      session[:open_groups][group.id] = (params[:open] == 'true') ? true : nil
    end
    render :nothing => true, :status => 200
    rescue ActiveRecord::RecordNotFound
      render :nothing => true, :status => 401
  end

end
