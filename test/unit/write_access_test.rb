require File.dirname(__FILE__) + '/../test_helper'

class WriteAccessTest < ActiveSupport::TestCase

  def setup
    @root     = create_root_user
    @admin    = create_admin_user
    @office   = Factory(:group, :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
    @sys      = Factory(:group, :parent => @office, :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
    @domains  = Factory(:group, :parent => @office, :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
    @clients  = Factory(:group, :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
    @sean     = Factory(:user)
  end

  context "When sean has write access to admin" do 
    setup do 
      @permission = Permission.create(:group => @sys, :user => @sean, 
        :mode => "WRITE", :admin_user => @root, :admin_password => CRYPTED_ADMIN_PASSWORD)
    end

    should "allow write access" do
      assert @sys.allows_write_access_for?(@sean)
    end

    context "and creates an entry" do 
      setup do
        @entry = Factory(:entry, :title => "Sean's Entry", :group => @sys)
        @entry.reload
      end

      should "allow sean to decrypt the entry" do
        assert @entry.decrypt_attributes_for(@sean, CRYPTED_USER_PASSWORD)
      end

      should "allow an admin to decrypt the entry" do
        assert @entry.decrypt_attributes_for(@admin, CRYPTED_ADMIN_PASSWORD)
      end

    end
  end
    
end
