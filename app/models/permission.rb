class Permission < ActiveRecord::Base
  
  VALID_MODES = ["ADMIN", "WRITE", "READ"]
  
  # Attributes containing the admin user, that is, 
  # the user creating the permission for the other
  # and granting that other user access to the group.
  attr_accessor :admin_password
  belongs_to :admin_user, :class_name => "User"
  
  belongs_to :user
  belongs_to :group
  
  validates_presence_of :user
  validates_presence_of :admin_user
  
  validates_presence_of :group
  validate :group_validations

  validates_uniqueness_of :user_id, :scope => :group_id,
    :message => "only one user permission per group, please"
  
  validates_inclusion_of :mode, :in => VALID_MODES, 
    :message => "mode should be either 'write' or 'read'"
    
  after_create    :grant_access
  after_destroy   :deny_access

  # Constrains write access to Admin and Write modes.
  def allows_write?
    ["ADMIN", "WRITE"].include?(self.mode)
  end  
    
  private
      
    # The conditions checked by these validations can't be 
    # created with the current UI. So they're just icing on the cake.
    def group_validations 
      return if self.group.nil? || self.user.nil? # Other validations catch these.
      group_is_root_or_child?
      adding_subgroup_with_existing_parent_permissions?
      adding_parent_with_existing_subgroup_permissions?
    end

    def group_is_root_or_child?
      if !self.group.root_or_first_child?
        self.errors.add(:group, "level too deep.")
      end  
    end 

    def adding_subgroup_with_existing_parent_permissions?
      if self.group.parent && self.user.groups.include?(self.group.parent)
        self.errors.add(:base, "User already has permission to the parent group.")
      end  
    end  
    
    def adding_parent_with_existing_subgroup_permissions?
      if self.group.parent.nil? && 
        self.group.children.any? {|child| self.user.groups.include?(child)}
        self.errors.add(:base, "To add parent group permission, remove the subgroup permissions first.")
      end
    end

    # Returns true if admin_user is root or 
    # if admin_user is an admin.
    def admin_user_permitted?
      self.admin_user.is_admin? || self.admin_user.is_root?
    end
  
    # Creates new crypted_attributes for every
    # entry in this group and in all subgroups.
    def grant_access
      raise AdminUserRequired unless admin_user_permitted?  
      self.group.all_entries.each do |entry|
        entry.create_crypted_attributes_for(self.user, self.admin_user, self.admin_password)
      end
    end
    
    # Removes all crypted attributes for every entry
    # in this group and all subgroups.
    def deny_access
      self.group.all_entries.each do |entry|
        entry.destroy_crypted_attributes_for(self.user)
      end
    end
  
end
