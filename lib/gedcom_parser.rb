
class GedcomParser
  
  # from  2 SURN Pack
  # extract "Pack"
  def self.extract_single_element element, text
    text =~ Regexp.new("\\d+ #{element} (.*)$")
    raise element + text unless $1
    $1.strip
  end
  
  def self.extract_level_down section_name, text
    #1 BIRT
    #2 DATE 18 Dec 1908
    #2 PLAC Kamas, Summit, Utah, United States
    out_lines = []
    hit_line_yet = false
    past_section = false
    text.lines.select{|l|
      if l =~ /^1 #{section_name}/
        raise if hit_line_yet
        hit_line_yet = true
      elsif l !~ /^2/ && hit_line_yet
        past_section = true
      end
      hit_line_yet && !past_section
    }.join
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
       gender = extract_single_element "SEX", text
       if gender == 'M'
         out[:gender] = 'Male'
       else
         out[:gender] = 'Female'
       end
       out
     }
  end
end