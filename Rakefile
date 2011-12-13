ENV['PATH'] = "C:\\Program Files (x86)\\Git\\cmd;" + ENV['PATH'] # real git.exe

require 'jeweler'
require 'os'
require 'fileutils'

Jeweler::Tasks.new do |s|
    s.name = "family_history_screen_saver"
    s.summary = File.read('README')
    s.add_dependency 'flickraw', '>= 0.9.5'
    s.add_dependency 'andand'
    s.add_dependency 'linguistics'
    s.add_dependency 'ruby-fs-stack'
    s.add_dependency 'jruby-openssl'
    s.add_dependency 'sane', '>= 0.25.0'
end

desc 'create distro zippable file'
task 'create_distro_dir' => 'gemspec' do 
  spec = eval File.read('family_history_screen_saver.gemspec')
  prefix = spec.name + "-" + spec.version.version
  dir_out = prefix + '/' + spec.name
  Dir[spec.name + '-*'].each{|old|
    p 'removing ' + old
    FileUtils.rm_rf old
  }
  raise 'unable to delete' if Dir[spec.name + '-*'].length > 0
  
  raise unless File.exist? 'vendor/jruby-complete.jar' 
  
  existing = Dir['*']
  FileUtils.mkdir_p dir_out
  FileUtils.cp_r(existing, dir_out)
  FileUtils.rm_rf Dir[dir_out + '/lib/java'] # don't distribute this
  # this one belongs in the trunk
  FileUtils.cp("#{dir_out}/run_family_history_screen_saver.bat", "#{dir_out}/..")
  p 'created (still need to zip it!) ' + dir_out
  raise unless OS.doze?
  raise unless system "\"c:\\Program Files\\7-Zip\\7z.exe\" a -tzip -r  #{prefix}.zip #{prefix}"
  p 'created ' + prefix + '.zip'

end
