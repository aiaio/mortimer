require 'abstract_unit'
require 'fixtures/user'

class SymmetricSentryCallbackTest < Test::Unit::TestCase
  fixtures :users
  
  def setup
    @str = 'sentry'
    Sentry::SymmetricSentry.default_key = @key = 'secret'
    @encrypted = "0XlmUuNpE2k=\n"
  end
  
  def test_should_encrypt_user_password
    u = SymmetricUser.new :login => 'bob'
    u.password = @str
    assert u.save
    assert_equal @encrypted, u.crypted_password
  end
  
  def test_should_decrypted_user_password
    assert_equal @str, users(:user_1).password
  end
  
  def test_should_return_nil_on_invalid_key
    Sentry::SymmetricSentry.default_key = 'other secret'
    assert_nil users(:user_1).password
  end
  
  def test_should_raise_error_on_invalid_key
    Sentry::SymmetricSentry.default_key = 'other secret'
    assert_raises(OpenSSL::CipherError) { users(:user_1).password! }
  end
end