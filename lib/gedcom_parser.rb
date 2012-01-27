
class GedcomParser
  
  # from  2 SURN Pack
  # extract "Pack"
  def self.extract_single_element element, text
    text =~ Regexp.new("\\d+ #{element} (.*)$")
    $1 ? $1.strip : nil
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
        if hit_line_yet
          raise 'has two? ' + section_name + text
        end
        hit_line_yet = true
      elsif l !~ /^2/ && hit_line_yet
        past_section = true
      end
      hit_line_yet && !past_section
    }.join
  end
  
  def self.get_subsection_element(section_name, element, text)
     subsection = extract_level_down section_name, text
     extract_single_element element, subsection
  end
  
  [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]

  def self.add_computed_distance individs, relat_hash
    me = individs[0]
	family_level_hash = {}
    compute_person_relation_level me, 0, relat_hash, family_level_hash
	for person in individs
	  if !person[:relation_level] && (level = family_level_hash[person[:fams]])
	    compute_person_relation_level person, level, relat_hash, family_level_hash
	  end
	end
  end
  
  def self.compute_person_relation_level person, level, relat_hash, family_level_hash
    person[:relation_level] = level
	if person[:fams] # dunno if this is a valid test for "real" gedcoms but...who knows...
	  # save away the level here.
	  if old_value = family_level_hash[person[:fams]]
	    raise "mismatch #{old_value} != #{level}" unless old_value == level # sanity check
	  else
	    family_level_hash[person[:fams]] = level
	  end
	end
    parents = relat_hash[person[:famc]]
    if parents # might not have any entered...
      for parent in parents
	    unless parent[:relation_level]
          compute_person_relation_level parent, level + 1, relat_hash, family_level_hash
		end
      end
    end
  end
  
  def self.parse_string full_text
     relat_hash = {}
     individs = full_text.split(/.*INDI.*/).reject{|t| t =~ /HEAD|TRLR/}.map{|indi_block| 
       #2 SURN Pack
       #2 GIVN Wesley Malin 
       out = {}
       name_with_slashes = extract_single_element "NAME", indi_block
       out[:name] = name_with_slashes.gsub('/', '')
       gender = extract_single_element "SEX", indi_block
       if gender == 'M'
         out[:gender] = 'Male'
       else
         out[:gender] = 'Female'
       end
       out[:birth_place] = get_subsection_element "BIRT", "PLAC", indi_block
      
       birth_date = get_subsection_element "BIRT", "DATE", indi_block
       birth_date =~ /(\d\d\d\d)/
       out[:birth_year] = $1
       out[:famc] = extract_single_element "FAMC", indi_block
       fams = extract_single_element "FAMS", indi_block
       out[:fams] = fams
       if fams # no kids, I think, or died early, or non marriage
         relat_hash[fams] ||= []
         relat_hash[fams] << out
       end
       out
     }
    add_computed_distance individs, relat_hash
    [individs, relat_hash]
  end
end