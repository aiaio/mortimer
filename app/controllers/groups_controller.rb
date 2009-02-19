class GroupsController < ApplicationController

  # An admin is required to create and delete groups.
  before_filter :admin_required, :only => [:new, :create, :destroy] 

  # Write permission (Admin, Write) required to edit and update a group.
  before_filter :write_permissions_required, :only => [:edit, :update]

  # Get groups in pairs.
  before_filter :groups_in_pairs
  
  # So that the user doesn't get logged out when editing groups.
  skip_before_filter :expire_session, :only => [:create, :update]
  before_filter :reset_session_expiry, :only => [:create, :update]
  
  # Get all groups to which the user has access.
  # This is the main method for viewing all groups / passwords
  # to which a user has access.
  def index
    @groups = Group.display_for_user(current_user)
  end

  # Render a new group.
  def new
    @group = Group.new 
  end

  # Create the new group.
  # Note: because all admin users will be
  # given immediate access to any newly-created group,
  # the admin user and password must be supplied.
  def create
    @group = Group.new(new_group_params)
    if @group.save
      redirect_to groups_url
    else
      render :template => "groups/new"
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    if @group.update_attributes(params[:group])
      flash[:notice] = "Group successfully updated."
      redirect_to groups_url
    else
      render :action => :edit
    end
  end  

  def destroy
    @group = Group.find(params[:id])
    if @group.destroy
      flash[:notice] = "Group successfully deleted."
      redirect_to groups_url
    else
      render :action => "edit"
    end  
  end  

  protected

    # Returns a new hash to ensure that the 
    # added admin user and password params
    # will never be passed back to the view.
    def new_group_params
      admin_params = {:admin_user => current_user, :admin_password => session[:pwd]}
      params[:group].merge(admin_params)
    end  

    # Returns groups is pairs, adding 'None'.
    def groups_in_pairs
      @groups = [['[None]', nil]] + Group.in_pairs 
    end  

end
