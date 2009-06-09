require File.dirname(__FILE__) + '/../test_helper'

class EntriesControllerTest < ActionController::TestCase

  context "When viewing an entry" do 
   setup do 
     @root  = create_root_user 
     @admin = create_admin_user  
     @user  = Factory(:user)
     @group, @entry = create_group_with_entry(@admin, ADMIN_PASSWORD)
   end

    context "A user with access" do 
      setup do
        @user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @admin, :admin_password => ADMIN_PASSWORD)                          
        login_as @user, "Secret@@"
        xhr :get, :show, :id => @entry
      end

      should_render_template "show" 
    end 

    context "A user without access" do 
      setup do 
        login_as @user, "secret@@"
      end   

      should "render access denied" do 
        xhr :get, :show, :id => @entry
        assert_access_denied
      end  
    end  

    context "and attempting to view without an xhr request" do
      setup do
        login_as @user, "secret@@" 
        get :show, :id => @entry
      end 

      should_redirect_to "home_url"
      should_set_the_flash_to /sorry/i
    end  

  end

  context "Basic actions:" do 
    setup do 
      @admin = create_admin_user
      @user  = Factory(:user)
      @group, @entry = create_group_with_entry(@admin, ADMIN_PASSWORD)
    end  

    context "on get new" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
        get :new
      end

      should_render_template "new"
    end

    context "on post create" do 
      setup do 
        login_as @admin, ADMIN_PASSWORD
        post :create, :entry => Factory.attributes_for(:entry).merge(:group_id => @group.id.to_s) 
      end

      should_change "Entry.count", :from => 1, :to => 2
    end  

    context "on get edit" do 
      setup do 
        login_as @admin, ADMIN_PASSWORD
        get :edit, :id => @entry
      end

      should_render_template "edit"
    end  

    context "on put update" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
        put :update, :id => @entry, :entry => {:title => "System"}
      end

      should "change the entry's title" do
      end
    end

    context "on destroy" do
      setup do 
        login_as @admin, ADMIN_PASSWORD
        delete :destroy, :id => @entry
      end

      should_change "Entry.count", :from => 1, :to => 0
    end  
  end  

  context "Authorization for basic users" do
    setup do
      @admin = create_admin_user
      @user  = Factory(:user)
      @group, @entry = create_group_with_entry(@admin, ADMIN_PASSWORD)
    end

    context "with read permissions:" do
      setup do 
        @user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @admin, :admin_password => ADMIN_PASSWORD)
        login_as @user, "Secret@@"
      end
   
      should "not access new" do
        get :new, :entry => {:group_id => @group.id}
        assert_access_denied
      end

      should "not access create" do
        post :create, :entry => {:group_id => @group.id}
        assert_access_denied
      end

      should "not access edit" do
        get :edit, :id => @entry
        assert_access_denied
      end

      should "not access update" do
        put :update, :id => @entry
        assert_access_denied
      end

      should "not access destroy" do
        delete :destroy, :id => @entry
        assert_access_denied
      end  
    end

    context "with write permissions:" do
      setup do 
        @user.permissions.create(:group => @group, :mode => "WRITE",
          :admin_user => @admin, :admin_password => ADMIN_PASSWORD)
        login_as @user, "Secret@@"
      end

      should "access new" do
        get :new, :entry => {:group_id => @group.id}
        assert_access_granted
      end

      should "access create" do
        post :create, :entry => @entry.attributes
        assert_access_granted 
      end

      should "access edit" do
        get :edit, :id => @entry
        assert_access_granted
      end

      should "access update" do
        put :update, :id => @entry, :entry => {:title => "BLAH"}
        assert_access_granted
      end

      should "not access destroy" do
        delete :destroy, :id => @entry
        assert_access_denied
      end  
    end  
  end  
end
