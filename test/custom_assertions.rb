# Assertions for testing access to actions.
module ThoughtBot # :nodoc:
  module Shoulda # :nodoc:
    module Assertions     
      def assert_access_granted 
        assert_no_match /you don't have access/i, flash[:notice]
      end

      def assert_access_denied
        assert_match /you don't have access/i, flash[:notice]
        assert_redirected_to home_url
      end  
    end
  end
end
