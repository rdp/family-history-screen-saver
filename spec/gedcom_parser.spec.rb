require 'rubygems'
require 'sane'
require 'rspec/autorun'
require_relative '../lib/gedcom_parser'

describe GedcomParser do

  def parse_small_gedcom
    text = File.read('small.ged')
    GedcomParser.parse_string(text)
  end
  
  it "should parse first entry in a gedcom" do
    parsed_result = parse_small_gedcom
    first_person = parsed_result[0].first
    for name,value in {
      :name => "Wesley Malin Pack",
      :gender => "Male",
      :birth_place => "Kamas, Summit, Utah, United States",
      :birth_year => '1908',
      :relation_level => 1   }
        first_person[name].should == value
    end
  end
  
  it "should add in relation levels for everybody, and non negative" do
    parsed_result = parse_small_gedcom
	people = parsed_result[0]
	for person in people
	  raise person.inspect unless person[:relation_level]
	  raise if person[:relation_level] < 0
	end
  end
  
  it "should compute relationship distance right" do
    individs = [{:name => 'me', :famc => 'parents1'}, {:name => 'dad1', :famc => 'parents2'}, {:name => 'gdad1', :famc => 'parents3_nonexist'}]
    relat_hash = {"parents1" => [individs[1]], "parents2" => [individs[2]]}
    GedcomParser.add_computed_distance individs, relat_hash, {}
    individs.map{|i| i[:relation_level]}.should == [0,1,2]
  end
  
  it "should extract single element" do
    GedcomParser.extract_single_element("GIVN", "\n2 GIVN Wesley Malin \n").should == "Wesley Malin"
    GedcomParser.extract_single_element("GIVN", "\n \n").should == nil # not found is ok too
  end
  
  it "should extract single elements" do
    GedcomParser.extract_single_elements("GIVN", "\n2 GIVN Wesley Malin \n2 GIVN yo").should == ["Wesley Malin", 'yo']    
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
  
  it "should parse dual marriage right" do
    two = GedcomParser.parse_file 'small_two_marriage.ged'
	for person in two[0]
	  raise person.inspect unless person[:relation_level]
	end
  end
  
  context "parsing large files" do
    malin = GedcomParser.parse_string(File.read('malin2.ged'))
    it "should parse large files" do
	  malin[0].length.should == 120
    end
	it "should add families in" do
	   File.write 'malin_inspect', malin.pretty_inspect
		for person in malin[0]
	      raise person.inspect unless person[:relation_level]
		end
	end
  end    
  
end