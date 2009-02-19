module Factories

  Factory.sequence :email do |n|
    "person#{n}@example.com" 
  end
  
  Factory.sequence :login do |n|
    "login#{n}"
  end
  
  Factory.define :user do |a|
    a.email                  { Factory.next(:email) }
    a.login                  { Factory.next(:login) }
    a.first_name             "test"
    a.last_name              "user"
    a.password               "Secret@@" 
    a.password_confirmation  "Secret@@" 
  end
  
end
