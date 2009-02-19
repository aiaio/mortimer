require File.dirname(__FILE__) + '/../test_helper'

class PermissionTest < ActiveSupport::TestCase

  def setup
    @root  = create_root_user
    @admin = create_admin_user
  end

  context "Relationships:" do
    should_belong_to :admin_user
    should_belong_to :user
    should_belong_to :group    
  end
  
  context "Validations: " do 
    setup do 
      @red_group  = Factory(:group)
      @blue_group = Factory(:group, :parent => @red_group)
      @deep_group = Factory(:group, :parent => @blue_group)
      @joe_user   = Factory(:user)
      @permission = Permission.create(:group => @red_group, :user => @joe_user, 
        :mode => "READ", :admin_user => @root, :admin_password => ADMIN_PASSWORD)
    end

    should_require_attributes :user, :group
    
    should_allow_values_for :mode, "ADMIN", "WRITE", "READ"

    should_require_unique_attributes :user_id, :scoped_to => :group_id, 
      :message => /one user permission/

    should "not create permission to the child group when a user has access to the root" do 
      @permission = Permission.create(:group => @blue_group, :user => @joe_user, 
        :mode => "READ", :admin_user => @root, :admin_password => ADMIN_PASSWORD)
      assert_match /User already has permission to the parent group/, @permission.errors[:base]
      assert @permission.new_record?
    end

    should "not allow a third-level group or deeper" do
      @permission.group = @deep_group
      assert !@permission.save
      assert_match /level too deep/, @permission.errors[:group]
    end

    context "When a user has access to a child-level group," do
      setup do 
        @bob_user   = Factory(:user) 
        @permission = Permission.create(:group => @blue_group, :user => @bob_user, 
          :mode => "READ", :admin_user => @root, :admin_password => ADMIN_PASSWORD)
      end

      should "not create permission to the parent group" do
        @permission = Permission.create(:group => @red_group, :user => @bob_user, 
         :mode => "READ", :admin_user => @root, :admin_password => ADMIN_PASSWORD) 
        assert_match /remove the subgroup permissions first/, @permission.errors[:base]
        assert @permission.new_record?
      end
    end  
  end  
  
  context "Adding and removing permissions: " do 
    setup do 
      @group       = Factory(:group, :admin_user => @root)
      @blue_group  = Factory(:group, :admin_user => @root)
      @joe_user    = create_admin_user
      @bob_user    = Factory(:user)
      
      @red_entry   = Factory(:entry, :title => "FIRST",  :group => @group)
      @blue_entry  = Factory(:entry, :title => "SECOND", :group => @group)
      @green_entry = Factory(:entry, :title => "THIRD",  :group => @group)
      @entry_not_in_group = Factory(:entry, :title => "MAIN", :group => @blue_group)
      @group.reload
    end
    
    context "a user without admin permission to a group" do 
      setup do 
        @user_lacking_permission   = Factory(:user)
        @user_with_read_permission = Factory(:user)
        @user_with_read_permission.permissions.create(:group => @group, 
          :mode => "READ", :admin_user => @root, :admin_password => ADMIN_PASSWORD)
      end
      
      should "not be able to grant access to that group" do 
        assert_raise(AdminUserRequired) do 
          @bob_user.permissions.create(:group => @group, :mode => "READ", 
            :admin_user => @user_lacking_permission, :admin_password => USER_PASSWORD)
        end
      end
      
      should "not be able to grant access even if user has read access" do 
        assert_raise(AdminUserRequired) do 
          @bob_user.permissions.create(:group => @group, :mode => "READ", 
            :admin_user => @user_with_read_permission, :admin_password => USER_PASSWORD)
        end
      end
    end
    
    context "a user is given group permission by an admin user: " do 
      setup do
        @joe_user.reload
        @permission = @bob_user.permissions.create(:group => @group, :mode => "READ", 
          :admin_user => @joe_user, :admin_password => ADMIN_PASSWORD)
        reload_activerecord_instances
      end
    
      should "add password entries for the new user" do
        @red_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
        assert_equal "crypted!", @red_entry.password
        @blue_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
        assert_equal "crypted!", @blue_entry.password
        @green_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
        assert_equal "crypted!", @green_entry.password
      end
      
      should "not add a password entry for an entry not in the group" do 
        assert_raise PermissionsError do 
          @entry_not_in_group.decrypt_attributes_for(@bob_user, USER_PASSWORD)
        end
      end
      
      context "when those permissions are destroyed" do 
        setup do 
          @permission.destroy  
          reload_activerecord_instances
        end  
        
        should "raise a Permissions error if an entry is accessed" do 
          assert_raise PermissionsError do 
            @red_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
          end
          
          assert_raise PermissionsError do 
            @blue_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
          end 
          
          assert_raise PermissionsError do 
            @green_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD)
          end
        end   
      end    

      context "the admin user is destroyed" do 
        setup do 
          @joe_user.destroy
          reload_activerecord_instances
        end
        
        should "remove permission from @bob_user" do 
          assert_raise(PermissionsError) { @red_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD) }
          assert_raise(PermissionsError) { @blue_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD) } 
          assert_raise(PermissionsError) { @green_entry.decrypt_attributes_for(@bob_user, USER_PASSWORD) } 
        end
      end
    end    
  end
end
