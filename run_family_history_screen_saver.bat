@setlocal
@rem disable any local rubyopt settings...
@set RUBYOPT=
@cd family_history_screen_saver && java -cp "./vendor/cache/jruby-complete-1.5.5.jar" org.jruby.Main screen_saver.rb || echo you need to install java first!