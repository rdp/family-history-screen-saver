require 'jeweler'
require 'os'

Jeweler::Tasks.new do |s|
    s.name = "family_history_screen_saver"
    s.summary = File.read('README')
    s.add_dependency 'flickraw'
    s.add_dependency 'andand'
    s.add_dependency 'ruby-fs-stack'
    #s.add_dependency 'sand'
end

desc 'create distro zippable file'

task 'create_distro_dir' => 'gemspec' do 
  require 'fileutils'
  require 'net/http'
  spec = eval File.read('family_history_screen_saver.gemspec')
  dir_out = spec.name + "-" + spec.version.version + '/' + spec.name
  FileUtils.rm_rf Dir[spec.name + '-*'] # remove old versions
  raise 'unable to delete' if Dir[spec.name + '-*'].length > 0
  
  unless File.exist? 'vendor/cache/jruby-complete-1.6.1.jar' 
   FileUtils.mkdir_p 'vendor/cache'
   puts 'downloading in jruby-complete.jar file' 
     # jruby complete .jar file
     Net::HTTP.start("jruby.org.s3.amazonaws.com") { |http|
       resp = http.get("/downloads/1.5.5/jruby-complete-1.5.5.jar")
       puts 'copying... '
       open("vendor/cache/jruby-complete-1.5.5.jar", "wb") { |file|
         file.write(resp.body)
       }
     }
  end
  
  existing = Dir['*']
  FileUtils.mkdir_p dir_out
  FileUtils.cp_r(existing, dir_out)
  # this one belongs in the trunk
  FileUtils.cp("#{dir_out}/run_family_history_screen_saver.bat", "#{dir_out}/..")
  p 'created (still need to zip it) ' + dir_out
end
