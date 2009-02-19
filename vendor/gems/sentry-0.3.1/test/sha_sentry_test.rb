require 'abstract_unit'
require 'fixtures/user'

class ShaSentryTest < Test::Unit::TestCase
  def setup
    Sentry::ShaSentry.salt = 'salt'
  end

  def test_should_encrypt
    assert_equal 'f438229716cab43569496f3a3630b3727524b81b', Sentry::ShaSentry.encrypt('test')
  end

  def test_should_encrypt_with_salt
    Sentry::ShaSentry.salt = 'different salt'
    assert_equal '18e3256d71529db8fa65b2eef24a69ddad7070f3', Sentry::ShaSentry.encrypt('test')
  end
  
  def test_should_encrypt_user_password
    u = ShaUser.new :login => 'bob'
    u.password = u.password_confirmation = 'test'
    assert u.save
    assert u.crypted_password = 'f438229716cab43569496f3a3630b3727524b81b'
  end
  
  def test_should_encrypt_user_password_without_confirmation
    u = DangerousUser.new :login => 'bob'
    u.password = 'test'
    assert u.save
    assert u.crypted_password = 'f438229716cab43569496f3a3630b3727524b81b'
  end
end