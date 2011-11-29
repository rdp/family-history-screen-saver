require 'jeweler'
require 'os'

Jeweler::Tasks.new do |s|
    s.name = "family_history_screen_saver"
    s.summary = File.read('README')
    s.add_dependency 'flickraw', '> 0.8.4' # also needs this commit https://github.com/hanklords/flickraw/commit/4297e5905e8d1cd6794d2141c155c0b6eb890fb2
    s.add_dependency 'andand'
    s.add_dependency 'linguistics'
    s.add_dependency 'ruby-fs-stack'
end

desc 'create distro zippable file'

task 'create_distro_dir' => 'gemspec' do 
  require 'fileutils'
  spec = eval File.read('family_history_screen_saver.gemspec')
  dir_out = spec.name + "-" + spec.version.version + '/' + spec.name
  FileUtils.rm_rf Dir[spec.name + '-*'] # remove old versions
  raise 'unable to delete' if Dir[spec.name + '-*'].length > 0
  
  raise unless File.exist? 'vendor/jruby-complete-1.6.1.jar' 
  
  existing = Dir['*']
  FileUtils.mkdir_p dir_out
  FileUtils.cp_r(existing, dir_out)
  # this one belongs in the trunk
  FileUtils.cp("#{dir_out}/run_family_history_screen_saver.bat", "#{dir_out}/..")
  p 'created (still need to zip it!) ' + dir_out
end
