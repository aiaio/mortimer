# Helper methods to be included in Test::Unit
module CustomTestHelpers

  # A default password for admins and root.
  ADMIN_PASSWORD = "Secret@@"
  
  # A default password for users.
  USER_PASSWORD  = "Secret@@"

  # A default password for entries.
  ENTRY_PASSWORD = "crypted!" 
  
  private
    # Creates a new admin user.
    def create_admin_user
      create_root_user unless root = User.root
      admin = Factory(:user, :password => ADMIN_PASSWORD, :password_confirmation => ADMIN_PASSWORD)
      admin.grant_admin(root, ADMIN_PASSWORD)
      return admin 
    end  

    # Creates a group with one entry.
    def create_group_with_entry(admin_user, admin_password)
      group = Factory(:group, :admin_user => admin_user, 
        :admin_password => admin_password)
      entry = Factory(:entry, :group => group)
      return [group, entry]
    end  

    # Creates the required superuser.
    def create_root_user
      @root = Factory(:user, :login => "root", :email => Factory.next(:email), :is_root => true, 
                     :password => ADMIN_PASSWORD, :password_confirmation => ADMIN_PASSWORD)
    end

    # Reload instances of ActiveRecord.
    def reload_activerecord_instances
      self.instance_variables.each do |ivar|
        if ivar.is_a?(ActiveRecord::Base) && ivar.respond_to?(:reload)
          ivar.reload
        end  
      end
    end

end
