require 'highline/import'

module AppSetup
  extend self

  def go
    display_setup_info
    generate_root_user
    generate_admin_user
  end
  
  private
  
    def display_setup_info
      puts "You are about to create the root accout"
      puts "along with an initial admin account."
      anykey
    end
  
    # Generate a root user for password backup purposes.
    def generate_root_user
      return if root_exists?
      input_loop do 
        email  = ask("Email:  ")
        @pass, @confirm = get_password
        @user = User.new(:login => "root", :first_name => "root", :last_name => "root",
          :password => @pass, :password_confirmation => @confirm, :email => email)
        @user.is_root = true
        @user.save
      end
      save_private_key_for(@user, @pass)
    end
    
    # Saves a private key to a file to a file for safe storage.
    def save_private_key_for(user, password)
      filename = "#{user.login}_key.rsa"
      f = File.new(filename, "w+")
      f << Sentry::AsymmetricSentry.decrypt_private_key(user.crypted_private_key, password)
      f.close
      puts "The private key for the #{user.login} accout has been saved to the file #{filename}."
      puts "Please store it in a safe place."
      anykey
    end

    # Generate the first admin user.
    def generate_admin_user
      return if admin_exists?
      puts "Now you'll create the first ADMIN user:"
      input_loop do 
        login, first, last, email = get_admin_details
        pass, confirm = get_password
        @user = User.new(:login => login, :password => pass, 
          :password_confirmation => confirm, :first_name => first, 
          :last_name => last, :email => email)
        @user.is_admin = true
        @user.save
      end
    end
    
    # Details needed to create an admin user.
    def get_admin_details
      [ask("Login:  "),
       ask("First name:  "),
       ask("Last name:  "),
       ask("Email:  ")]
    end
        
    # Get a password and confirmation that match.
    def get_password
      pass, confirm = nil, nil
      while pass.nil? || pass != confirm
        pass    = ask("Password:  ") { |q| q.echo = "*" }
        confirm = ask("Enter password again:  ") { |q| q.echo = "*" }
        puts "Password do not match!\n" if pass != confirm
      end
      return [pass, confirm]
    end
  
    # Make sure that no root user exists.
    def root_exists?
      if User.root
        puts "\n** Error: a ROOT user already exists!  Moving on to admin user. **\n"
        return true
      else
        return false
      end
    end
    
    # Make sure that no admin users exist.
    def admin_exists?
      if User.admins.empty?
        return false
      else  
        puts "\n** Error: an ADMIN user already exists! **\n"
        return true
      end
    end
    
    # Display errors on an AR object.
    def display_errors(object)
      puts "Please correct the following errors: " unless object.errors.blank?
      object.errors.each do |k, v|
        puts "#{k}:"
        v.each {|message| puts "   - #{message}"}
      end
    end
    
    # Input loop for user creation.
    def input_loop
      @user = nil
      while @user.nil? || !@user.errors.blank?
        yield
        display_errors(@user)
      end
    end

    # Standard "press any key to continue."
    def anykey
      puts "Press any key to continue..."
      STDIN.getc
    end
  
end
