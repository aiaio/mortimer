require File.dirname(__FILE__) + '/../test_helper'

class SentryTest < ActiveSupport::TestCase

  def setup
    @sentry = Sentry::AsymmetricSentry
    keys    = @sentry.generate_random_rsa_key('secret')
    @public_key  = keys[:public]
    @private_key = keys[:private] 
  end

  context "Sentry" do
    setup do 
      @text = "Let me not to the marriage of true minds Admit impediments: love is not love Which alters when it alteration finds."
    end

    should "encrypt a string up to 117 characters." do
      encrypted = @sentry.encrypt_to_base64_with_key(@text, @public_key)
    end

  end
end
