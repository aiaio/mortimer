module CustomAuthorizationMethods
  protected
    # Is the current user an admin?	
    def admin_required
      if !current_user.is_admin?
        raise AccessDenied
      end
    end

    # Are the user requested and current user the same?
    def owner_required
      find_user
      admin_required unless @user == current_user
    end

    # Does the current user have write/admin access to the given resource?
    def write_permissions_required
      record = controller_class.find(params[:id])
      admin_required unless record.allows_write_access_for?(current_user)
    end

    # Get ActiveRecord class corresponding to the controller.
    def controller_class
      self.controller_name.capitalize.singularize.constantize
    end  
  
    # Store failed authorization attempts in the main log file.
    def note_access_denied(exception)
      logger.warn "Security Exception (#{exception}): Access denied for '#{current_user.login}' from #{request.remote_ip} at #{Time.now.utc}, attempting '#{request.request_uri}', (#{self.controller_name}: #{self.action_name})."
    end
end

