require 'abstract_unit'

class SymmetricSentryTest < Test::Unit::TestCase
  def setup
    @str = 'sentry'
    @key = 'secret'
    @encrypted = "0XlmUuNpE2k=\n"
    @sentry = Sentry::SymmetricSentry.new
    Sentry::SymmetricSentry.default_key = nil
  end
  
  def test_should_encrypt
    assert_equal @encrypted, @sentry.encrypt_to_base64(@str, @key)
  end
  
  def test_should_decrypt
    assert_equal @str, @sentry.decrypt_from_base64(@encrypted, @key)
  end

  def test_should_encrypt_with_default_key
    Sentry::SymmetricSentry.default_key = @key
    assert_equal @encrypted, @sentry.encrypt_to_base64(@str)
  end
  
  def test_should_decrypt_with_default_key
    Sentry::SymmetricSentry.default_key = @key
    assert_equal @str, @sentry.decrypt_from_base64(@encrypted)
  end

  def test_should_raise_error_when_encrypt_with_no_key
    assert_raises(Sentry::NoKeyError) { @sentry.encrypt_to_base64(@str) }
  end

  def test_should_raise_error_when_decrypt_with_no_key
    assert_raises(Sentry::NoKeyError) { @sentry.decrypt_from_base64(@str) }
  end
end