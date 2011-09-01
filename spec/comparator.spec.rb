
require 'rubygems'
require 'rspec/autorun'
require 'sane'
require_relative '../lib/screen_saver'
require_relative '../lib/comparator'
require_relative 'given.rb'

describe M::ShowImage do
  
  given "two genealogies" do
    @ancestors1 = eval(File.read('ancestors.rb'))
    @ancestors2 = eval(File.read('ancestors2.rb'))
  end
  
  it "should report no match if there is none" do
    Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should =~ /no match/i
  end
  
  it "should tell you you are cousins" do
    @ancestors2 << {:name=>"Don Elbert Pack",
      :afn=>"KWQC-VTP",  :relation_level=>2} # common grandpa...
    Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should == 'cousins'
  end

  it "should tell you you are self" do
    @ancestors2 << {:name=>"Don Elbert Pack",
      :afn=>"KWQC-VTP",  :relation_level=>0} # common self
    Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should == 'self'
  end
  
  
end