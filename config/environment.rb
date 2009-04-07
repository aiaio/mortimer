require File.join(File.dirname(__FILE__), "boot")

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  # This project does not use ActiveResource.
  config.frameworks -= [:active_resource]

  # Gem configuration.
  config.gem "sentry"
  config.gem "rubyist-aasm",            :lib => "aasm"
  config.gem "highline"
  
  # Gems for testing.
  config.gem "thoughtbot-shoulda",      :lib => "shoulda/rails"
  config.gem "thoughtbot-factory_girl", :lib => "factory_girl"
  config.gem "mocha"
  
  # Use ssl_requirement exception_notification plugin.
  config.plugins = [ :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use UTC by default.
  config.time_zone = "UTC"

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, "my", "locales", "*.{rb,yml}")]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you"ll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => "_cipher_safe_session",
    :secret      => "f7c48e8519307fcca9e779a6da67932d4ca473a7056c3bdc32420101192c22fc7c33844c76de698e86967"
  }

  # Since we"ll be storing user passwords needs to be stored in the session.
  config.action_controller.session_store = :cookie_store

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
end

require "exception_classes"
