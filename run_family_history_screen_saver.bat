@setlocal
@rem disable any local rubyopt settings...
@set RUBYOPT=
@cd family_history_screen_saver && java -cp "./vendor/jruby-complete.jar" org.jruby.Main bin/screen_saver