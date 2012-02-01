
class GedcomParser
  
  # from  2 SURN Pack
  # extract "Pack"
  def self.extract_single_element element, text
    text =~ Regexp.new("\\d+ #{element} (.*)$")
    $1 ? $1.strip : nil
  end
  
  def self.extract_single_elements element, text
    text.scan(Regexp.new("\\d+ #{element} (.*)$")).map{|element| element[0].strip}
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

  def self.add_computed_distance individs, relat_hash, family_level_hash
    me = individs[0]
    compute_person_relation_level me, 0, relat_hash, family_level_hash
	for person in individs
	  # TODO this doesn't go *down* the tree very well, I don't think...hmm...which may be ok for now...
	  if !person[:relation_level] 
	    if level = family_level_hash[person[:fams]]
		  # a spouse
	      compute_person_relation_level person, level, relat_hash, family_level_hash
	    elsif level = family_level_hash[person[:famc]]
		  # a child
	      compute_person_relation_level person, level-1, relat_hash, family_level_hash
		else
		  #puts 'no relation level please report' # happens too frequently unfortunately...
		end
	  end
	end
	
	min = individs.map{|i| i[:relation_level] || 0}.min
	if min < 0
	  for person in individs
	    person[:relation_level] -= min if person[:relation_level]
	  end
	end
	
  end
  
  private
  def self.compute_person_relation_level person, level, relat_hash, family_level_hash
    person[:relation_level] = level
	if person[:fams] # dunno if this is a valid test for "real" gedcoms but...who knows how messed up they might get...
	  # save their family level, for spouses later
	  if old_value = family_level_hash[person[:fams]]
	    raise "mismatch #{old_value} != #{level}" unless old_value == level
	  else
	    family_level_hash[person[:fams]] = level
	  end
	end
    if parents = relat_hash[person[:famc]]
      for parent in parents
	    unless parent[:relation_level]
          compute_person_relation_level parent, level + 1, relat_hash, family_level_hash
		end
      end
    end
  end
  
  public
  def self.parse_file filename
    parse_string File.read(filename)
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
       if fams
         relat_hash[fams] ||= []
         relat_hash[fams] << out
       else
	     # absent for whatever reason
	   end
       out
     }
	fam_hash = {}
    add_computed_distance individs, relat_hash, fam_hash
    [individs, relat_hash, fam_hash]
  end
end