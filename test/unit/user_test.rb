require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  
  context "User relationships:" do 
    should_have_many :groups, :through => :permissions
    should_have_many :granted_permissions, :dependent => :destroy
  end
  
  context "A newly-created user" do 
    setup do 
      @user = Factory(:user)
    end
    
    should "have a public key" do 
      assert_match /RSA PUBLIC KEY/, @user.public_key
    end
    
    should "have a private key symetrically encrypted with the password" do 
      key = Sentry::SymmetricSentry.decrypt_from_base64(@user.crypted_private_key, USER_PASSWORD)
      assert_match /RSA PRIVATE KEY/, key
    end

    context "when updating password" do 
      setup do 
        @user.update_attributes(:password => "Unknown$$", :password_confirmation => "Unknown$$", 
          :old_password => USER_PASSWORD)
      end

      should "re-encrypt the private key with the new password" do 
        key = Sentry::SymmetricSentry.decrypt_from_base64(@user.crypted_private_key, "Unknown$$")
        assert_match /RSA PRIVATE KEY/, key
      end
    end

    context "(with two permissions)" do
      setup do 
        @admin = create_admin_user
        @red_group, @red_entry   = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
        @blue_group, @blue_entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)

        @user.permissions.create(:group => @red_group, :mode => "READ",
          :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @user.permissions.create(:group => @blue_group, :mode => "READ",
          :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
        @old_permissions = @user.permissions
        reload_activerecord_instances
      end  

      should "have access to entries" do
        @red_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)
        assert @red_entry.password
        @blue_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)
        assert @blue_entry.password
      end

      context "and after resetting the user's password" do
        setup do 
          @new_password = @user.reset_password(@admin, CRYPTED_ADMIN_PASSWORD)
          @user.reload
        end

        should "successfully change the user's password" do
          assert_equal @user, User.authenticate(@user.login, @new_password)
        end  

        should "still have access to the entries" do
          @red_entry.decrypt_attributes_for(@user, SessionPasswordEncryptor.encrypt(@new_password))
          assert @red_entry.password

          @blue_entry.decrypt_attributes_for(@user, SessionPasswordEncryptor.encrypt(@new_password))
          assert @blue_entry.password
        end  

        should "have the same permissions" do
          assert_equal @old_permissions.size, @user.permissions.size
          @user.permissions.each do |p|
            assert(@old_permissions.detect {|o| o.group_id == p.group_id && o.mode == p.mode})
          end
        end
      end  
    end  
  end
  
  context "Convenience finders:" do 
    should "get the root user if it exists" do 
      create_root_user 
      assert User.root
    end
    
    should "return nothing if the root user doesn't exist" do 
      assert_nil User.root
    end
  end

  context "When one root user exists: " do
    setup { create_root_user }
    
    should "be impossible to create a second root user" do
      new_root = Factory.build(:user)
      new_root.is_root = true
      new_root.save
      assert_match /one root user/, new_root.errors[:base]
    end

    should "be impossible to delete root" do
      root = User.root
      assert !root.destroy
      assert_match /cannot delete the root user/i, root.errors[:base]
    end

  end

  context "An admin user" do 
    setup do
      @root  = create_root_user 
      @admin = create_admin_user
    end

    context "when several entries and groups exist" do 
      setup do 
        Entry.new
        @group       = Factory(:group, :admin_user => @admin)
        @red_entry   = Factory(:entry, :group => @group)
        @blue_entry  = Factory(:entry, :group => @group)

        @blue_group  = Factory(:group, :admin_user => @admin)
        @green_entry = Factory(:entry, :group => @blue_group)
      end

      context "and a new admin user is created" do 
        setup do 
          @new_admin = create_admin_user
          reload_activerecord_instances
        end

        should "grant all access to the new admin user" do 
          @red_entry.decrypt_attributes_for(@new_admin, CRYPTED_ADMIN_PASSWORD)
          assert @red_entry.password

          @blue_entry.decrypt_attributes_for(@new_admin, CRYPTED_ADMIN_PASSWORD)
          assert @blue_entry.password

          @green_entry.decrypt_attributes_for(@new_admin, CRYPTED_ADMIN_PASSWORD)
          assert @green_entry.password
        end

      end   
    end

    should "not be possible to delete if it's the only admin" do
      assert !@admin.destroy
      assert_match /last admin/, @admin.errors[:base] 
    end

    should "be deletable if another admin user exists" do 
      @new_admin = Factory(:user) 
      @new_admin.password = nil
      @new_admin.grant_admin(@root, CRYPTED_ADMIN_PASSWORD)
      assert @admin.destroy
    end
    
  end
end
