# Code to make sure that base conditions exist for running the password app.
# Verifies that:
# 1. A root user exists.
# 2. An admin user exists.
# 3. The root's private key has been copied out of the Rails root folder.
module SetupVerifier
  class ApplicationSetupError < StandardError; end
  extend self

  def verify
    return unless initialized?
    verify_root
    verify_admin
    verify_root_key
  end

  protected

  # Determine whether to run the setup verifier.
  # Should not be run for rake tasks, tests, etc.
  def initialized?
    if ENV["RAILS_ENV"] == "test" || !User.table_exists? || $setup_disabled 
      return false
    else  
      $tmp_env = ENV["RAILS_ENV"] || "development"
      return true
    end  
  end

  # Does a root user exist?
  def verify_root
    if !User.root
      raise ApplicationSetupError, "\n\n**Error: No root user exists! Please run 'rake setup RAILS_ENV=#{$tmp_env}' to create the root user.**\n\n\n"
    end
  end

  # Does an admin user exist?
  def verify_admin
    if User.admins.blank?
      raise ApplicationSetupError, "\n\n**Error: No admin user exists! Please run 'rake setup RAILS_ENV=#{$tmp_env}' to create an initial admin user.**\n\n\n"
    end  
  end	

  # Has the user copied (or renamed) the root key file?
  def verify_root_key
    root_key_file = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "root_key.rsa"))
    if File.exist?(root_key_file)
      raise ApplicationSetupError, "\n\n**Error: The file #{root_key_file} must be moved out of the root folder. Keep it in a secure location for emergency password recovery.**\n\n\n"
    end  
  end
end

SetupVerifier.verify
