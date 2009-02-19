require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < ActionController::TestCase
  
  context "Basic actions: " do 
    setup do 
      @admin = create_admin_user
      @user  = Factory(:user)
    end
    
    context "on get index" do 
      setup do 
        login_as @user
        get :index
      end

      should_render_template "index"
    end  

    context "on get new" do 
      setup do 
        login_as @admin
        get :new
      end  

      should_respond_with    :success
      should_render_template "new"
    end  

    context "on post create" do 
      setup do 
        login_as @admin
        post :create, :group => {:title => "VPS Password"}
      end  
      
      should_change "Group.count", :from => 0, :to => 1 
    end  
  end

  context "GroupController Authorization:" do 
    setup do 
      @admin = create_admin_user
      @user  = Factory(:user)
    end

    context "the admin" do 
      setup { login_as @admin }

      should "access index" do 
        get :index
        assert_access_granted
      end  

      should "access new" do 
        get :new
        assert_access_granted
      end

      should "access create" do 
        post :create, :group => {:title => "TestingGroup"}
        assert_access_granted
      end  

      should "access delete" do
        @group = Factory(:group)
        delete :destroy, :id => @group.id
        assert_access_granted
      end  
    end  

    context "a normal user" do
      setup { login_as @user }

      should "not access new" do 
        get :new
        assert_access_denied
      end   

      should "not access create" do 
        post :create
        assert_access_denied
      end 

      should "not access delete" do
        @group = Factory(:group)
        delete :destroy, :id => @group.id
        assert_access_denied
      end  
    end  
  end
end
