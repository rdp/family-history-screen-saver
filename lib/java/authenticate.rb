require 'java'
require 'sane'

# TODO this file only in jar...

def translate string
  out = ''
  string.each_byte{|b| b += 3; out << b}
  out
end

def authenticate_me(com, user, pass)
  
  # string[1,2,3] => [k,u,p]
  string1 = translate(Java::Helper.string1)
  com.key = string1
  com.identity_v1.authenticate :username => user, :password => pass
end