# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # Of course, login cannot be required to log in!
  skip_before_filter :login_required, :expire_session

  # Use the login layout.
  layout "login"  

  # Show the login template.
  def new
  end

  # Logout from any current session and authenticate the user. 
  # Note: the plain-text password is stored in the session
  # in order to decrypt the user's private key. This is essential.
  #
  # Therefore, it is important to consider session storage security.
  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if !user
      note_failed_signin
      flash[:notice] = "Invalid email or password."
      @login       = params[:login]
      render :action => 'new'
    elsif user_has_permissions?(user)
      session[:pwd] = SessionPasswordEncryptor.encrypt(params[:password])
      session[:open_groups] = {}
      self.current_user = user
      redirect_back_or_default('/')
    end
  end

  # Log the user out.
  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  protected

    # Store failed sign-in attempts in the main log file.
    def note_failed_signin
      logger.warn "Security: Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
    end

    def user_has_permissions?(user)
      if !user.is_admin? && user.permissions.blank?
        flash[:notice] = "You currently have no permissions. Please contact an admin."
        render :action => 'new'
        return false
      else
        return true
      end
    end

end
