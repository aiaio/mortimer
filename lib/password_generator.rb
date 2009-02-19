# Generates a random user password.
class PasswordGenerator
  
  Numbers   = (1..10).to_a
  Lower     = ("a".."z").to_a 
  Upper     = ("A".."Z").to_a
  Chars     = Lower + Upper + Numbers 

  # Password satisfies app requirements:
  # At least eight characters, at least one upper-case letter, 
  # and at least two non-word characters.
  def self.random
    upper     = (1..2).map {|n| Upper[rand(Upper.size)]}
    numbers   = (1..2).map {|n| Numbers[rand(Numbers.size)]}
    remaining = (1..(rand(3) + 5)).map {|n| Chars[rand(Chars.size)]}
    password = remaining + upper + numbers
    (1..password.length).map {|n| password.delete_at(rand(password.length))}.join
  end

end
