
require 'rubygems'
require 'rspec/autorun'
require 'sane'
require_relative '../lib/screen_saver'
require_relative '../lib/comparator'
require_relative 'given.rb'

describe M::ShowImage do
  
  before do # TODO given
    @ancestors1 = eval(File.read('ancestors.rb'))
    @ancestors2 = eval(File.read('ancestors2.rb'))
  end
  
  it "should report no match if there is none" do
    Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should =~ /no match/i
  end
  
  {2 => "cousins", 0 => "self", 1 => "brother/sister"}.each{|level, expected_answer|
    it "should tell you you are various direct relationships" do
      @ancestors2 << {:name=>"Don Elbert Packlocal",
        :afn=>"KWQC-VTPlocal",  :relation_level=>level}
      @ancestors1 << {:name=>"Don Elbert Packlocal",
        :afn=>"KWQC-VTPlocal",  :relation_level=>level}
      Comparator.tell_me_relationship_between(@ancestors2, @ancestors1).should == expected_answer
    end
  }
  
end