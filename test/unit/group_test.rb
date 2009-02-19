require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase

  def setup
    create_root_user
    create_admin_user
  end  
  
  context "Group relationships" do
    should_have_many :entries
    should_have_many :users, :through => :permissions
  end

  context "When an admin exists" do 
    setup do 
      @admin = Factory(:user)
      @admin.grant_admin(@root, "secret@@")
    end

    context "and a new group is created" do 
      setup do
        @group = Factory(:group, :admin_user => @root)
      end
      
      should "grant permissions to the admin user" do 
        @admin.reload
        assert @admin.permissions.find(:first, :conditions => {:group_id => @group.id})
      end
    end
  end

  context "A group with one sub-group" do
    setup do 
      @group     = Factory(:group)
      @sub_group = Factory(:group, :parent => @group) 
    end

    should "not be deletable" do
      assert !@group.destroy
      assert_match /not empty/, @group.errors[:base]
    end  

    should "delete the empty sub-group" do
      assert @sub_group.destroy
    end 
  end  

  context "A group with one entry" do
    setup do 
      @group = Factory(:group)
      @entry = Factory(:entry, :group => @group)
    end  
    
    should "not be deletable" do
      assert !@group.destroy
      assert_match /not empty/, @group.errors[:base]
    end  
  end  
  
end
