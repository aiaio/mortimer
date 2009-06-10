require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < ActionController::TestCase

  context "User Authorization:" do 
    setup do 
      @user  = Factory(:user)
      @user2 = Factory(:user)
      @admin = create_admin_user
    end

    context "with a logged-in admin user:" do 
      setup { login_as @admin }

      should "access to index" do
        get :index
        assert_template /index/
      end   

      should "access edit" do 
        get :edit, :id => @user.id
        assert_template /edit/
      end

      should "access update" do 
        get :update, :id => @user.id, :user => {:login => "somenewlogin"}
        assert_redirected_to edit_user_path(@user)
      end  

      should "access create" do 
        get :create
        assert_no_match /you don't have access/i, flash[:notice]
      end  

      should "access toggle admin" do 
        get :toggle_admin, :id => @user.id
        assert_redirected_to edit_user_path(@user)
      end  

      should "access reset password" do
        post :reset_password, :id => @user.id
        assert_match /new password/i, flash[:notice]
      end  
    end

    context "with a logged-in base user" do
      setup { login_as @user }

      should "not access index" do 
        get :index
        assert_access_denied
      end  

      should "not access destroy" do 
        post :destroy, :id => @user
        assert_access_denied
      end

      should "not access toggle admin" do 
        post :toggle_admin, :id => @user
        assert_access_denied
      end

      should "not access reset password" do
        post :reset_password, :id => @admin.id
        assert_access_denied
      end 

      should "not access new" do 
        get :new
        assert_access_denied
      end

      should "not access create" do 
        post :create
        assert_access_denied
      end  

      should "not access edit" do 
        get :edit, :id => @user
        assert_access_denied
      end  

      should "not access update" do 
        put :update, :id => @user
        assert_access_denied
      end  
    end
  end

  context "Restful Authentication Tests:" do 
    setup do 
      create_root_user
      @admin_user = Factory(:user) 
      @admin_user.grant_admin(@root, "secret@@")
      @request.session[:user_id] = @admin_user.id
    end

    should "allow signup" do
      assert_difference 'User.count' do
        create_user
      end
    end
  
    should "require login on signup" do
      assert_no_difference 'User.count' do
        create_user(:login => nil)
        assert assigns(:user).errors.on(:login)
        assert_response :success
      end
    end
  
    should "require password on signup" do
      assert_no_difference 'User.count' do
        create_user(:password => nil)
        assert assigns(:user).errors.on(:password)
        assert_response :success
      end
    end
  
    should "require password confirmation on signup" do
      assert_no_difference 'User.count' do
        create_user(:password_confirmation => nil)
        assert assigns(:user).errors.on(:password_confirmation)
        assert_response :success
      end
    end
  
    should "require email on signup" do
      assert_no_difference 'User.count' do
        create_user(:email => nil)
        assert assigns(:user).errors.on(:email)
        assert_response :success
      end
    end
    
  end
  
  protected
    def create_user(options = {})
      post :create, :user => { :login => 'quire', :email => 'quire@example.com',
        :password => 'Quire699', :password_confirmation => 'Quire699' }.merge(options)
    end
end
