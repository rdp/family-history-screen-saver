require 'ostruct'

class GedcomParser
  
  # from  2 SURN Pack
  # extract "Pack"
  def self.extract_single_element element, text
    text =~ Regexp.new("\\d+ #{element} ([\\w ]+)")    
    $1.strip
  end
       [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]

  def self.parse_string text
    
     text.split(/.*INDI.*/).select{|t| t =~ /INDI/}.map{|big_block| 
       #2 SURN Pack
       #2 GIVN Wesley Malin 
       out= OpenStruct.new
       big_block =~
       surname = 
       out.new 
      
     }
  end
end