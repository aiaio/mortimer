module Factories

  Factory.sequence :entry_title do |n|
    "Entry_#{n}"
  end

  Factory.define :entry do |a|
    a.title                 { Factory.next(:entry_title) }
    a.username              "joeuser"
    a.password              "crypted!" 
    a.password_confirmation "crypted!" 
    a.group_id              "1"
  end
  
end

