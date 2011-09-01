
require 'rubygems'
require 'rspec/autorun'
require 'sane'
require_relative '../lib/screen_saver'

describe M::ShowImage do
  
  given "a shared grandfather" do
    @ancestors1 = eval(File.read('ancestors.rb'))
    @ancestors2 = eval(File.read('ancestors.rb'))
  end
  
  it "should tell you you are cousins" do
    [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
            :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]
  end
end