module AuthenticatedTestHelper

  # Sets the current user. 
  # Optionally sets plain-text password
  def login_as(user, password=nil)
    @request.session[:user_id] = user.attributes["id"]
    @request.session[:pwd]     = password
  end

  # Mock http authorization.
  def authorize_as(user)
    @request.env["HTTP_AUTHORIZATION"] = user ? ActionController::HttpAuthentication::Basic.encode_credentials(users(user).login, 'monkey') : nil
  end
  

end
