# Allows for password recovery given the root key.
# This will always be invoked with the recover_passwords rake task.
module PasswordRecovery
  extend self

  def recover!
    verify_root
    add_root_decrypter_to_entries
    write_passwords_to_file
  end

  private

  def verify_root
    raise StandardError, "Root user required!" unless User.root
    root_key_path = File.expand_path(File.join(File.dirname(__FILE__), "..", "root_key.rsa"))
    raise StandardError, "Root key required!" unless File.exist?(root_key_path)
    @root_key = File.open(root_key_path).read
  end

  def write_passwords_to_file
    @password_file = File.new(File.join(File.dirname(__FILE__), "..", "passwords.txt"), "w")
    @groups = Group.roots
    @groups.each do |group|
      @password_file << group.title + "\n"
      group.all_entries.each do |entry|
        entry.decrypt_attributes_for_root(@root_key)
        @password_file << render_entry(entry) 
      end
      @password_file << "\n\n"
    end
    @password_file.close
  end

  def add_root_decrypter_to_entries
    Entry.send :include, AttributeDecrypter
  end

  def render_entry(entry)
    [entry.title, entry.username, entry.password, entry.url, entry.notes, entry.description].join(", ") + "\n"
  end

  module AttributeDecrypter
    # Decrypt any encrypted attributes for the given
    # permitted user, and place the decrypted values
    # in their corresponding virtual (non-saved) attributes.
    def decrypt_attributes_for_root(root_key)
      root = User.root
      raise PermissionsError if user_crypted_attributes(root).blank?

      user_crypted_attributes(root).each do |crypted_attr|
        next if crypted_attr.nil? # Don't try to decrypt if nil.
        data = Base64.decode64(crypted_attr.data)
        self.send(crypted_attr.setter, OpenSSL::PKey::RSA.new(root_key).private_decrypt(data))
      end

      rescue StandardError => error
        p error
    end 
  end

end
