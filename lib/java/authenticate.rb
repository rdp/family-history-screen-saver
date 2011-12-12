require 'java'
require 'sane'

# TODO this file only in jar...

def translate string
  out = ''
  string.each_byte{|b| b += 3; out << b}
  out
end

def authenticate_me(com)
  
  # string[1,2,3] => [k,u,p]
  string1 = Java::Helper.string1
  string2 = Java::Helper.string2 # TODO prompt...
  string3 = Java::Helper.string3
  com.key = translate(string1)
  com.identity_v1.authenticate :username => translate(string2), :password => translate(string3)
end