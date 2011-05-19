def authenticate_me(com)
  com.key = File.read('key')
  com.identity_v1.authenticate :username => 'api-user-1033', :password => File.read('pass')
end