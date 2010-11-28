require 'jeweler'
require 'os'

Jeweler::Tasks.new do |s|
    s.name = "family_history_screen_saver"
    # s.summary = "an EDL scene-selector/bleeper that works with online players like hulu"
    # s.email = "rogerdpack@gmail.com"
    # s.homepage = "http://github.com/rdp"
    # s.authors = ["Roger Pack"]
    # s.add_dependency 'sane', '>= 0.22.0'
    # s.add_dependency 'rdp-win32screenshot', '>= 0.0.7.3'
    # s.add_dependency 'mini_magick', '>= 3.1' # for ocr...
    # s.add_dependency 'whichr', '>= 0.3.6'
    # s.add_dependency 'jruby-win32ole'
    # s.add_dependency 'rdp-ruby-wmi'
    # s.add_dependency 'ffi' # mouse, etc.
    # s.add_development_dependency 'rspec' # prefer rspec 2 I guess...
    # s.add_development_dependency 'jeweler'
    # s.add_development_dependency 'hitimes' # now jruby compat!
    # s.extensions = ["ext/mkrf_conf.rb"]
end

desc 'create distro zippable file'
task 'create_distro_dir' do
  require 'fileutils'
  spec = eval File.read('sensible-cinema.gemspec')
  dir_out = spec.name + "-" + spec.version.version + '/' + spec.name
  FileUtils.rm_rf Dir[spec.name + '-*'] # remove old versions
  raise 'unable to delete' if Dir[spec.name + '-*'].length > 0
  
  existing = Dir['*']
  FileUtils.mkdir_p dir_out
  FileUtils.cp_r(existing, dir_out)
  # this one belongs in the trunk
  FileUtils.cp("#{dir_out}/run_sensible_cinema.bat", "#{dir_out}/..")
  p 'created (still need to zip it) ' + dir_out
end
