class Group < ActiveRecord::Base
  acts_as_tree :order => "title"
  
  # Must supply an admin user and password when creating
  # a group in order to grant admins permission.
  attr_accessor :admin_user, :admin_password

  has_many :entries, :order => "entries.title"
  has_many :users, :through => :permissions
  has_many :permissions, :dependent => :destroy

  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :parent_id

  # Scopes.
  named_scope :ordered, :order => :title
  named_scope :with_entries, :include => :entries, :order => "groups.title, entries.title"

  # Callbacks.
  before_create :build_admin_permissions
  before_destroy :verify_empty

  # Generates an array like the following:
  #   [["Root", 1], ["Root - Child", 2], ["Root - Child - Child", 3]]
  # If no initial group is supplied, all root-level groups are used to start.
  # Used to generate options for select on groups.
  def self.in_pairs(groups = [], parent_name = "", list = [])
    groups = (groups.empty? && parent_name.blank?) ? self.roots : groups
      groups.each do |group|
        name = (parent_name.blank? ? parent_name : "#{parent_name} - ") + group.title
        list << [name, group.id]
        list = in_pairs(group.children, name, list)
      end  
    return list
  end  
  
  # Generates an array of groups with the following constraints:
  #   # User cannot have access to the group.
  #   # If the user has access to a sub-group, then don't display the parent group.
  #   # If user has access to the parent group, don't display the sub-group.
  #   # Only descend one level.
  def self.non_permitted_for_user(user_groups=[], groups = [], parent_name = "", list = [], level=0)
    return list if level > 1
    groups = (groups.empty? && parent_name.blank?) ? self.roots : groups
      groups.each do |group|
        next if level == 0 && user_groups.any? {|g| g == group}
        next if level == 1 && user_groups.any? {|g| g == group}
        name = (parent_name.blank? ? parent_name : "#{parent_name} - ") + group.title
        list << [name, group.id] unless level == 0 && user_groups.any? {|g| g.parent == group}
        list = non_permitted_for_user(user_groups, group.children, name, list, level+1)
      end  
    return list
  end 

  # Returns an array of recursively-nested groups like the following:
  #   [[red_group, [red_group_child1, red_group_child2]]]
  # In general, the first element is a group, and the second element
  # is a list of all child groups, recursively.
  # If no initial groups are supplied, all root-level groups are used.
  # Used for displaying nested groups on the main passwords page.
  def self.nested(groups = [], depth=0)
    list = []
    groups = (groups.nil? && depth==0) ? self.roots : groups
      groups.each do |group|
        list << if !group.children.blank?  
          [group, nested(group.children, depth+1)]
        elsif group.parent.blank?
          [group]
        else 
          group
        end  
      end
    return list
  end  

  def self.display_for_user(user)
    nested(user.root_level_groups).sort {|a, b| a[0].title <=> b[0].title }
  end 

  # All entries in this group and in all subgroups.
  def all_entries
    Group.nested([self]).flatten.inject([]) do |total, group| 
      total << group.entries
    end.flatten  
  end  

  # The permitted users are linked to the 
  # root-level group only.
  def permitted_users
    self.root.users
  end  

  # Does given user have write permissions to this group?
  def allows_write_access_for?(user)
    permission = user.permissions.detect {|p| p.group == self.root}
    permission && permission.allows_write?
  end  

  # Does this group have any child groups for password entries?
  def has_children_or_entries?
    !self.children.empty? || !self.entries.empty?
  end  

  # Is this a root- or first-child level group?
  def root_or_first_child?
    self.parent.nil? || self.parent.parent.nil?
  end  

  # Label field shows a group's parents.
  #   Web Services - Google
  def title_with_parents
    return self.title if self.parent.nil?
    self.parent.title + " - " + self.title
  end  

  private

    # When a new group is created, give permission to all admins. 
    # But only if this is a root-level group. 
    def build_admin_permissions
      return unless self.parent.nil?
      User.admins.each do |admin|
        self.permissions.build(:user_id => admin.id, :mode => "ADMIN", 
          :admin_user => self.admin_user, :admin_password => self.admin_password)
      end
    end

    # Should not delete if a group contains either sub-groups or entries.
    def verify_empty
      unless self.children.blank? && self.entries.blank?
        self.errors.add(:base, "Group not empty!")
        return false
      end  
    end  

end
  
