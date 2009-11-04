# Generates a random user password.
class PasswordGenerator
  
  Numbers   = (1..10).to_a
  Lower     = ("a".."z").to_a 
  Upper     = ("A".."Z").to_a
  Symz     	= ["!","@","#","$","%","^","&","*"]
  Chars     = Lower + Upper + Numbers + Symz

  # Password satisfies app requirements:
  # At least ten characters, at least one upper-case letter, 
  # and at least two non-word characters.
  def self.random
    upper     = (1..2).map {|n| Upper[rand(Upper.size)]}
    numbers   = (1..2).map {|n| Numbers[rand(Numbers.size)]}
    symz 	  = (1..2).map {|n| Symz[rand(Symz.size)]}
    remaining = (1..(rand(3) + 6)).map {|n| Chars[rand(Chars.size)]}
    password = remaining + upper + numbers + symz
    (1..password.length).map {|n| password.delete_at(rand(password.length))}.join
  end

end
