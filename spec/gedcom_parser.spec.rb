require 'rubygems'
require 'sane'
require 'rspec/autorun'
require_relative '../lib/gedcom_parser'

     [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]

describe GedcomParser do
   it "should parse gedcoms" do
    text = File.read('small.ged')
    parsed_result = GedcomParser.parse_string(text)
    first_person = parsed_result[0].first
    for name,value in {
      :name => "Wesley Malin Pack",
      :gender => "Male",
      :birth_place => "Kamas, Summit, Utah, United States",
      :birth_year => '1908'
      
      }
      first_person[name].should == value
    end
    
    pp parsed_result[1]
    
  end
  
  it "should extract single elements" do
    GedcomParser.extract_single_element("GIVN", "\n2 GIVN Wesley Malin \n").should == "Wesley Malin"
    GedcomParser.extract_single_element("GIVN", "\n \n").should == nil # not found is ok too
  end
  
  it "should extract levels" do
    test_level =  <<-EOL
0 IND
1 BIRT
2 DATE 18 Dec 1908
2 PLAC Kamas, Summit, Utah, United States
1 YOYO
    EOL
    
    out = GedcomParser.extract_level_down "BIRT", test_level
    out.lines.to_a.length.should == 3
    out = GedcomParser.get_subsection_element "BIRT",  "DATE", test_level
    out.should == "18 Dec 1908"
  end
  
  it "should parse "
  
  it "should parse large files" do
    GedcomParser.parse_string(File.read('malin2.ged'))[0].length.should == 120
  end
    
  
end