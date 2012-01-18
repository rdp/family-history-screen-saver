require 'rubygems'
require 'sane'
require 'rspec/autorun'
require_relative '../lib/gedcom_parser'


     [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]


describe GedcomParser do
   it "should parse gedcoms" do
    text = File.read('small.ged')
    parsed = GedcomParser.parse_string text
    first_person = parsed.first
    for name,value in {:name => "Wesley Malin Pack"}
      first_person[name].should == value
    end
  end
  
  it "should extract single elements" do
    GedcomParser.extract_single_element("GIVN", "\n2 GIVN Wesley Malin \n").should == "Wesley Malin"
  end
end