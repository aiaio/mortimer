require 'abstract_unit'

class AsymmetricSentryTest < Test::Unit::TestCase
  def setup
    @str = 'sentry'
    @key = 'secret'
    @public_key_file = File.dirname(__FILE__) + '/keys/public'
    @private_key_file = File.dirname(__FILE__) + '/keys/private'
    @encrypted_public_key_file = File.dirname(__FILE__) + '/keys/encrypted_public'
    @encrypted_private_key_file = File.dirname(__FILE__) + '/keys/encrypted_private'
    @sentry = Sentry::AsymmetricSentry.new
    
    @orig = 'sentry'
    @data = "vYfMxtVB8ezXmQKSNqTC9sPgi8TbsYRxWd7DVbpprzyuEdZ7gftJ/0IXsbXm\nXCU08bTAl0uEFm7dau+eJMXEJg==\n"
    @encrypted_data = "q2obYAITmK93ylzVS01mJx1jSlnmylMX15nFpb4uKesVgnqvtzBRHZ/SK+Nm\nEzceIoAcJc3DHosVa4VUE/aK/A==\n"
    Sentry::AsymmetricSentry.default_public_key_file = nil
    Sentry::AsymmetricSentry.default_private_key_file = nil
  end
  
  def test_should_decrypt_files
    set_key_files @public_key_file, @private_key_file
    assert_equal @orig, @sentry.decrypt_from_base64(@data)
  end
  
  def test_should_decrypt_files_with_encrypted_key
    set_key_files @encrypted_public_key_file, @encrypted_private_key_file
    assert_equal @orig, @sentry.decrypt_from_base64(@encrypted_data, @key)
  end

  def test_should_read_key_files
    assert !@sentry.public?
    assert !@sentry.private?
    set_key_files @public_key_file, @private_key_file
  end
  
  def test_should_read_encrypted_key_files
    assert !@sentry.public?
    assert !@sentry.private?
    set_key_files @encrypted_public_key_file, @encrypted_private_key_file
  end

  def test_should_decrypt_files_with_default_key
    set_default_key_files @public_key_file, @private_key_file
    assert_equal @orig, @sentry.decrypt_from_base64(@data)
  end
  
  def test_should_decrypt_files_with_default_encrypted_key
    set_default_key_files @encrypted_public_key_file, @encrypted_private_key_file
    assert_equal @orig, @sentry.decrypt_from_base64(@encrypted_data, @key)
  end

  def test_should_decrypt_files_with_default_key_using_class_method
    set_default_key_files @public_key_file, @private_key_file
    assert_equal @orig, Sentry::AsymmetricSentry.decrypt_from_base64(@data)
  end
  
  def test_should_decrypt_files_with_default_encrypted_key_using_class_method
    set_default_key_files @encrypted_public_key_file, @encrypted_private_key_file
    assert_equal @orig, Sentry::AsymmetricSentry.decrypt_from_base64(@encrypted_data, @key)
  end

  def test_should_read_key_files_with_default_key
    assert !@sentry.public?
    assert !@sentry.private?
    set_default_key_files @public_key_file, @private_key_file
  end
  
  def test_should_read_encrypted_key_files_with_default_key
    assert !@sentry.public?
    assert !@sentry.private?
    set_default_key_files @encrypted_public_key_file, @encrypted_private_key_file
  end

  private  
  def set_key_files(public_key, private_key)
    @sentry.public_key_file = public_key
    @sentry.private_key_file = private_key
    assert @sentry.private?
    assert @sentry.public?
  end
  
  def set_default_key_files(public_key, private_key)
    Sentry::AsymmetricSentry.default_public_key_file = public_key
    Sentry::AsymmetricSentry.default_private_key_file = private_key
    assert @sentry.private?
    assert @sentry.public?
  end
end