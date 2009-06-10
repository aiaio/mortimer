module SessionPasswordEncryptor
  extend self

  def encrypt(password)
    Sentry::SymmetricSentry.encrypt_to_base64(password, SESSION_PASSWORD_KEY)
  end

end
