@setlocal
@rem disable any local rubyopt settings...
@set RUBYOPT=
@java -version|| echo "need to install java first" && pause && goto end
@cd family_history_screen_saver && call java -cp "./vendor/jruby-complete-1.6.6.jar" org.jruby.Main bin/screen_saver --gedcom
:end