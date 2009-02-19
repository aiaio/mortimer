class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include CustomAuthorizationMethods
  helper :all
 
  # Ssl is required in production mode.
  before_filter :require_ssl_in_production 

  # Login is required for every action, 
  # except those in the session contoller (skipped there).
  before_filter :login_required

  # Expire the session if inactivity period has elapsed.
  before_filter :expire_session

  # Capture AccessDenied, PermissionsError, and RecordNotFound.
  around_filter :rescue_exceptions 

  # Adds forgery protection; since we're using cookie-session-store,
  # the :secret parameter is unnecessary.
  protect_from_forgery
  
  # Don't log passwords, password_confirmations, usernames, or urls. 
  filter_parameter_logging :password, :password_confirmation, :username, :url

  protected
    
    # Find the given user.
    def find_user
      @user = User.find(params[:id])
    end

    # Rescue common exception classes, particularly
    # AccessDenied, PermissionsError, and ActiveRecord::RecordNotFound.
    def rescue_exceptions
      begin
        yield
      rescue AccessDenied, PermissionsError => exception 
        flash[:notice] = "You don't have access to that! Attempt logged."
        redirect_to home_url 
        note_access_denied(exception)
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Error: Could not find that record."
        redirect_to home_url
      end
    end

    # The app must be run across SSL in production.
    def require_ssl_in_production
      return unless ENV["RAILS_ENV"] == "production"
      if !request.ssl?
        redirect_to "https://" + request.host + request.request_uri
        flash.keep
        return false
      end
    end  
    
    # Expires the session after a certain inactivity period.
    # See config/security.rb to set the interval.
    def expire_session
      if session_expired?
        redirect_to login_url 
      end

      reset_session_expiry
      return true
    end

    # Assigns a new session expiry whether the session has expired or not.
    def reset_session_expiry
      session[:expiry_time] = SESSION_EXPIRE_INTERVAL.from_now
      return true
    end

    # Is the session expired?
    def session_expired?
      return false unless !session[:expiry_time].nil? && session[:expiry_time] < Time.now
      logout_killing_session!
      flash[:notice] = "Your session has timed out. Please log in again."
    end

end
