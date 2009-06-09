require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  
  # Adds callbacks to generate public and (encrypted) 
  # private keys when a new user is created.
  include Sentry::RsaKeyGeneration
  
  has_many :groups, :through => :permissions, :order => "groups.title"
  has_many :permissions
  
  # If this user is an admin user, this user will have granted
  # several permissions. This way, if the admin user is deleted, then
  # so are the permissions granted by that user.
  has_many :granted_permissions, :class_name => "Permission", 
    :foreign_key => "admin_user_id", :dependent => :destroy

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :first_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :first_name,     :maximum => 100
  
  validates_format_of       :last_name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message
  validates_length_of       :last_name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  validate :ensure_only_one_root_user

  # Only the following attributes can be affected by mass-assignment.
  attr_accessible :login, :email, :first_name, :last_name, :old_password, :password, :password_confirmation

  # Returns all admins
  named_scope :admins, :conditions => {:is_admin => true}

  # List of all users except root
  named_scope :index, :conditions => {:is_root => false}, :order => "last_name, first_name"

  # ***** Callbacks ***** #
  before_destroy :fail_if_deleting_last_admin, :fail_if_deleting_root

  # ***** Class Methods ***** #
  # Return the root user.
  def self.root
    find :first, :conditions => {:is_root => true}
  end
  
  # Authenticates a user by login name and unencrypted password.  
  # Returns the user or nil.
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => {:login => login}
    u && u.authenticated?(password) ? u : nil
  end

  # ***** Instance Methods ***** #
  # Write login attribute.
  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  # Write email attribute.
  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end
  
  # Allows an admin to reset a user's password.
  # This requires the generation of a brand new
  # key pair and the re-encryption of the user's 
  # crypted passwords. This is accomplished by recreating
  # the user's permissions.
  def reset_password(admin_user, admin_password)
    self.transaction do 
      @resetting_password = true
      new_password = generate_new_password
      reset_permissions(admin_user, admin_password)
      save
      return new_password
      @resetting_password = false
    end  
  end 
  
  # Make this user an admin user.
  # Remove any permissions/crypted passwords
  # associated with this user, and then grant this 
  # user access to each entry.
  def grant_admin(admin_user, admin_password)
    self.transaction do 
      # Need to make sure we're not resetting the password.
      self.password = nil
      self.is_admin = true
      self.permissions.delete_all
      grant_admin_permissions_for_all_groups(admin_user, admin_password)
      self.save
    end
  end

  # Revoke this user's admin rights.
  def revoke_admin
    self.transaction do 
      # Need to make sure we're not resetting the password.
      self.password = nil
      self.is_admin = false
      self.permissions.each {|p| p.destroy }
      self.save
    end
  end

  # User can view entries in this group if the user 
  # has access to the group itself or to an ancestor of the given group.
  def can_view_entries_for?(group)
    group.self_and_ancestors.any? {|g| self.groups.include?(g)}
  end

  # Groups to which the user does belong
  def permitted_groups
    self.groups
  end
  
  # Groups to which the user does not belong
  def non_permitted_groups
    (Group.roots - self.groups).map {|g| [g.title, g.id]}
  end

  # Top-level groups
  def root_level_groups
    self.groups.map {|group| group.parent.nil? ? group : group.parent}.uniq
  end  
  
  def full_name
    self.first_name + " " + self.last_name
  end

  private

    # Make sure that only one root user can be created.
    def ensure_only_one_root_user
      if self.is_root? && User.root 
        self.errors.add(:base, "Only one root user is allowed!")
        return false
      else
        return true
      end
    end

    # Make sure that there's always at least
    # one admin user.
    def fail_if_deleting_last_admin
      return true if !self.is_admin? || User.admins.size >= 2
      self.errors.add(:base, "Cannot delete the last admin user.")
      return false
    end

    # Can't delete the root user.
    def fail_if_deleting_root
      return true unless self.is_root?
      self.errors.add(:base, "Cannot delete the root user.")
      return false
    end  

    # Adds an admin-level permission for each top-level group.
    # This will create a crypted password for the new admin
    # for each password entry in the system.
    def grant_admin_permissions_for_all_groups(admin_user, admin_password)
      Group.roots.each do |group|
        self.permissions.create(:group => group, :mode => "ADMIN",
          :admin_user => admin_user, :admin_password => admin_password)
      end
    end
 
    # Generates a random password for the user.
    # This method is used by #reset_password, and
    # should return the new password.
    def generate_new_password 
      new_password    = PasswordGenerator.random
      self.password   = new_password
      self.password_confirmation = new_password
      generate_rsa_keys
      save
      reload
      return new_password
    end
    
    # Resets the user's permissions after the RSA keys
    # have been replaced. Used by #reset_password.
    def reset_permissions(admin_user, admin_password)
      old_permissions = self.permissions.map do |p| 
        {:group_id => p.attributes["group_id"], :mode => p.attributes["mode"]}
      end  
      self.permissions.delete_all
      save
      Entry # Required to make sure that subclasses are loaded.
      CryptedAttribute.for_encrypter(self).each {|p| p.destroy}
      old_permissions.each do |p|
        permission_attributes = p.merge(:admin_user_id => admin_user.id, :admin_password => admin_password)
        self.permissions.create(permission_attributes)
      end
    end  

    def resetting_password?
      @resetting_password
    end  

end
