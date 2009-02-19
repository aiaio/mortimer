# General error class for the app.
class PasswordAppError < StandardError; end

# Tried to decrypt without permissions.
class PermissionsError < PasswordAppError; end

# Tried to grant access without an admin user. 
class AdminUserRequired < PasswordAppError; end

# Raised if db doesn't contain a root user account.
class MissingRootUser < PasswordAppError; end

# Raised when a user attempts to access an unauthorized action.
class AccessDenied < PasswordAppError; end
