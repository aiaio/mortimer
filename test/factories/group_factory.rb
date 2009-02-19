module Factories

  Factory.sequence :group_title do |n|
    "GroupTitle_#{n}"
  end  

  Factory.define :group do |a|
    a.title  { Factory.next(:group_title) }
  end
  
end
