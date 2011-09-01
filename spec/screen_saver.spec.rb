
require 'rubygems'
require 'rspec/autorun'
require 'sane'
require_relative '../lib/screen_saver'
require_relative '../lib/comparator'
require_relative 'yo.rb'

describe M::ShowImage do
  
  #  _dbg
  given "a shared grandfather" do
    @ancestors1 = eval(File.read('ancestors.rb'))
    @ancestors2 = eval(File.read('ancestors.rb'))
  end
  
  it "should tell you you are cousins" do
    Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should == 'cousins'
  end
end