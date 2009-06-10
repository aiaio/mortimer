require File.dirname(__FILE__) + '/../test_helper'

# Users can be granted permissions to root-level groups only.
# Thus, when given access to a root-level group, users must also
# be given permission to all entries in any subgroups.
# That feature is tested here.
class SubGroupPermissionsTest < ActiveSupport::TestCase
 
  def setup
    @root  = create_root_user
		@admin = create_admin_user
  end

	context "Creating a subgroup entry" do
    setup do 
      @blue_group, @blue_entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
			@square_group = Factory(:group, :parent => @blue_group)
			@square_entry = Factory(:entry, :group  => @square_group)
    end 

		should "grant the admin user access to the subgroup" do
		  assert @square_entry.decrypt_attributes_for(@admin, CRYPTED_ADMIN_PASSWORD)				
			assert_equal ENTRY_PASSWORD, @square_entry.password 
		end				
	end

	context "Several groups and subgroups with entries" do
    setup do 
      @blue_group, @blue_entry = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
			@red_group, @red_entry   = create_group_with_entry(@admin, CRYPTED_ADMIN_PASSWORD)
			@square_group = Factory(:group, :parent => @blue_group)
			@square_entry = Factory(:entry, :group  => @square_group)
			reload_activerecord_instances
    end 

		context "and a user is given access to a parent group" do
      setup do 
			  @user = Factory(:user)
				@permission = @user.permissions.create(:group => @blue_group, :mode => "READ",
				  :admin_user => @admin, :admin_password => CRYPTED_ADMIN_PASSWORD)
				reload_activerecord_instances
		  end				

			should "grant permission to the root group's entry" do
			  assert @blue_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)				
				assert_equal ENTRY_PASSWORD, @blue_entry.password 
			end    

			should "grant permission to the child group's entry" do
			  assert @square_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)				
				assert_equal ENTRY_PASSWORD, @square_entry.password 
			end				

			context "and the user is denied access" do
        setup do
				  @user.permissions.each(&:destroy)
				  reload_activerecord_instances
				end	

			  should "deny permission to the root group's entry" do
		      assert_raise PermissionsError do
			      assert @blue_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)				
          end
			  end

			  should "deny permission to the child group's entry" do
			    assert_raise PermissionsError do
			      assert @square_entry.decrypt_attributes_for(@user, CRYPTED_USER_PASSWORD)				
          end
			  end
			end
		end	
	end				
end 
