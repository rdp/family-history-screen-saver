
class GedcomParser
  
  # from  2 SURN Pack
  # extract "Pack"
  def self.extract_single_element element, text
    text =~ Regexp.new("\\d+ #{element} (.*)$")
    raise element + text unless $1
    $1.strip
  end
  
       [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]

  def self.parse_string text
     text.split(/.*INDI.*/).reject{|t| t =~ /HEAD|TRLR/}.map{|big_block| 
       #2 SURN Pack
       #2 GIVN Wesley Malin 
       out = {}
       name_with_slashes = extract_single_element "NAME", big_block
       out[:name] = name_with_slashes.gsub('/', '')
       out
     }
  end
end