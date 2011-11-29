@setlocal
@rem disable any local rubyopt settings...
@set RUBYOPT=
@cd family_history_screen_saver\bin && java -cp "../vendor/jruby-complete-1.6.1.jar" org.jruby.Main --1.9 screen_saver