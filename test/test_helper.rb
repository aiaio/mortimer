ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
$:.unshift(File.dirname(__FILE__))

require "test_help"
require "shoulda"
require "factory_girl"
require "mocha"
require "custom_assertions"
require "custom_test_helpers"

# Require Factories
Dir.entries(File.join(File.dirname(__FILE__), "factories")).each do |f| 
  require File.join(File.dirname(__FILE__), "factories", f) if f =~ /\.rb$/
end    

# Custom helpers can be found in custom_test_helpers.rb.
class Test::Unit::TestCase
  include Factories 
  include AuthenticatedTestHelper
  include CustomTestHelpers

  self.use_transactional_fixtures = true
end
