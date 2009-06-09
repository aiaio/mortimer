ActionController::Routing::Routes.draw do |map|

  map.logout "/logout", :controller => "sessions", :action => "destroy"
  map.login  "/login",  :controller => "sessions", :action => "new"

  map.resources :users,  :member => {:toggle_admin => :post, :reset_password => :post}
  map.resource  :user_password
  map.resources :settings
  map.resources :groups, :entries, :permissions
  map.resource  :session
  
  map.home "/",
    :controller => "groups",
    :action     => "index"

end
