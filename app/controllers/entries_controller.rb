class EntriesController < ApplicationController
   
  # Admin required to delete.
  before_filter :admin_required, :only => :destroy

  # Write permissions required for new (see action), create, edit, and update.
  before_filter :write_permissions_required, :only => [:edit, :update]
  before_filter :write_permissions_on_new,   :only => [:new, :create]

  # Make sure that the show command can only be executed via xhr.
  verify :xhr => true, :only => :show, :add_flash => {:notice => "Sorry, Charile :)"}, :redirect_to => "/" 

  # Find entries and get groups for the appropriate actions.
  before_filter :find_entry, :only => [:show, :edit, :update, :destroy]
  before_filter :groups_in_pairs, :only => [:new, :create, :edit, :update]

  # So that the user doesn't get logged out when editing groups.
  # Note: session expiration for the #show action is handled within in the action itself.
  skip_before_filter :expire_session, :only => [:create, :update, :show]
  before_filter :reset_session_expiry, :only => [:create, :update]

  # If the current user does not have access to the requested password,
  # the method entry#decrypt_attributes_for will raise an exception.
  # Thus, a user can hit this action as many times as he likes,
  # as it will submit the same password each time, rendering a brute-force attack impossible.
  #
  # Also note that exceptions raised here will be logged as security warnings.
  # See application_controller.rb for details.
  def show
    if session_expired?
      render :text => login_url, :status => 401
    else
      @entry.decrypt_attributes_for(current_user, session[:pwd])
	  render :template => "entries/show", :layout => false
	  
    end
    rescue AccessDenied, PermissionsError => exception 
      flash[:notice] = "You don't have access to that! Attempt logged."
      note_access_denied(exception)
      render :text => login_url, :status => 401
  end

  # Before filter isn't used to check permissions because
  # we need an instantiated group to check.
  # See #write_permissions_on_new.
  def new
    @entry = Entry.new(params[:entry])
    @random_password = PasswordGenerator.random
  end

  # See #write_permissions_on_new.
  def create
    @entry = Entry.new(params[:entry])
    if @entry.save
      open_entry_group(@entry)
      redirect_to groups_path
    else
      render :template => "entries/new"
    end   
  end

  # See before_filters for code. 
  def edit
    @entry.decrypt_attributes_for(current_user, session[:pwd])
    @entry.password = nil # Don't want to show this on edit.
  end
  
  def update
    if @entry.update_attributes(params[:entry])
      redirect_to groups_url
      flash[:notice] = "Password entry updated."
    else
      render :action => :edit
    end
  end

  def destroy
    if @entry.destroy
      flash[:notice] = "Entry successfully deleted."
    end
    redirect_to groups_url
  end
  
  protected

    # Get available groups for html select element.
    def groups_in_pairs
      @groups = Group.in_pairs(current_user.groups)
    end  

    # Find the entry with specified id.
    def find_entry
      @entry = Entry.find(params[:id])
    end  

    # Checking for write permissions requires
    # instantiating the group. Used only with #new and #create.
    def write_permissions_on_new
      return if current_user.is_admin?
      raise ActiveRecord::RecordNotFound if params[:entry].nil?
      @group = Group.find(params[:entry][:group_id])
      raise AccessDenied unless @group.allows_write_access_for?(current_user)
    end

    # Make sure that the groups in the list are open.
    def open_entry_group(entry)
      session[:open_groups] ||= {}
      entry.group.self_and_ancestors.each do |group|
        session[:open_groups][group.id] = true
      end
    end
end
