require File.dirname(__FILE__) + '/../test_helper'

class EntryTest < ActiveSupport::TestCase
  
  def setup
    @root  = create_root_user
    @admin = create_admin_user
  end

  context "Relationships:" do 
    should_belong_to :group
  end

  context "Validations:" do
    should_require_attributes :group, :title, :username, :password
    should_ensure_length_in_range :password, (6..40)
    should_ensure_length_in_range :title, (2..40)
  end  
  
  context "With three users, " do 
    setup do 
      @group = Factory(:group, :admin_user => @root, :admin_password => ADMIN_PASSWORD)
      @joe_user = Factory(:user, :password => "English@@!!", 
                           :password_confirmation => "English@@!!")
      @bob_user = Factory(:user, :password => "Swedish@@!!", 
                           :password_confirmation => "Swedish@@!!")
      @user3 = Factory(:user) 
      @new_admin = create_admin_user
    end
    
    context "Two of whom have permissions to the test group - " do 
      setup do 
        @joe_user.permissions.create(:group => @group, :mode => "WRITE", 
          :admin_user => @root, :admin_password => ADMIN_PASSWORD)
        @bob_user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @root, :admin_password => ADMIN_PASSWORD)
        @entry = Factory(:entry, :title => "MAIN", :group => @group)
      end
      
      should "create a password entry for the first user" do 
        assert @entry.decrypt_attributes_for(@joe_user, "English@@!!")
      end
      
      should "create a password entry for the second user" do 
        assert @entry.decrypt_attributes_for(@bob_user, "Swedish@@!!")
      end
      
      should "create a password entry for the root user" do 
        assert @entry.decrypt_attributes_for(@root, ADMIN_PASSWORD)
      end

      should "create a password entry for the admin user" do 
        assert @entry.decrypt_attributes_for(@new_admin, ADMIN_PASSWORD)
      end
      
      should "raise a Permissions error if the third user tries to decrypt" do 
        assert_raises ::PermissionsError do
          @entry.decrypt_attributes_for(@user3, "Secret@@")
        end
      end      
    end
    
    context "A new entry is created: " do
      setup do 
        @entry = Factory(:entry, :title => "WEB", :group => @group)
        reload_activerecord_instances
      end

      should "grant access to admin" do 
        @entry.decrypt_attributes_for(@admin, ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password       
      end

      should "grant access to admin 2" do
        @entry.decrypt_attributes_for(@new_admin, ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password        
      end

      should "grant access to root" do
        @entry.decrypt_attributes_for(@root, ADMIN_PASSWORD)
        assert_equal "crypted!", @entry.password    
      end
    end

    context "Two users with access to a group" do 
      setup do 
        @joe_user.permissions.create(:group => @group, :mode => "WRITE",
          :admin_user => @root, :admin_password => "secret@@!!")
        @bob_user.permissions.create(:group => @group, :mode => "READ",
          :admin_user => @root, :admin_password => "secret@@!!")
        @entry = Factory(:entry, :title => "MAIN", :group => @group)
      end
      
      should "decrypt for the first user" do 
        @entry.decrypt_attributes_for(@joe_user, "English@@!!")
        assert_equal "crypted!", @entry.password
      end
      
      should "not decrypt if a bad password is entered" do 
        assert_raises PermissionsError do
          @entry.decrypt_attributes_for(@joe_user, "wrong_pass")
        end
      end
      
      should "decrypt for the second user" do 
        @entry.decrypt_attributes_for(@bob_user, "Swedish@@!!")
        assert_equal "crypted!", @entry.password
      end
      
      context "when the password changes" do
        setup do 
          @entry.update_attributes(:password => "Vault@@@", 
                                   :password_confirmation => "Vault@@@")
        end
        
        should "decrypt for the first user" do 
          @entry.decrypt_attributes_for(@joe_user, "English@@!!")
          assert_equal "Vault@@@", @entry.password
        end
          
        should "decrypt for the second user" do 
          @entry.decrypt_attributes_for(@bob_user, "Swedish@@!!")
          assert_equal "Vault@@@", @entry.password
        end
      end
      
    end
  end
end
