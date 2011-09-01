require 'linguistics' # gem

class Comparator
  
  def self.tell_me_relationship_between x_ancestors, y_ancestors
    # they look like...
=begin
     {:name=>"Don Elbert Pack",
  :relation_level=>2,
  :gender=>"Male",
  :birth_place=>"Salt Lake City, Salt Lake, Utah, United States",
  :birth_year=>1873,
  :image_note_urls=>["http://dl.dropbox.com/u/40012820/johnpack1.jpg"],
  :afn=>"KWQC-VTPfake"},
=end

    hashed_x = hash_by_afn x_ancestors
    best_ancestor_relat = 1_000_000
    best_ancestor = nil
    y_ancestors.each{|ancestor|
      if hashed_x[ancestor[:afn]]
        p best_ancestor_relat , ancestor[:relation_level]
        if best_ancestor_relat > ancestor[:relation_level]
          # we have a winner
          best_ancestor = ancestor
          best_ancestor_relat = ancestor[:relation_level]
        end
      end
    }
    
    case best_ancestor_relat
    when 1_000_000
      'no match--you\'re not related!'
    when 0
      'self'
    when 1
      'brother/sister'
    when 2
      'cousins'
    else
#     Linguistics::EN.ordinal 33 => 33rd
      first_word = ordinalize(best_ancestor_relat - 1) #Linguistics::EN.ordinal(best_ancestor_relat-1)
      "#{first_word} cousin"
    end
    
  end
  
  def self.index_for(position) 
    (0..4).to_a.send(position)
  end
  
  def self.hash_by_afn x_ancestors
    by_afn = {}
    x_ancestors.each{|ancestor|
      by_afn[ancestor[:afn]] = ancestor
    }
    by_afn
  end
  
      # Turns a number into an ordinal string used to denote the position in an
    # ordered sequence such as 1st, 2nd, 3rd, 4th.
    #
    # Examples:
    #   ordinalize(1)     # => "1st"
    #   ordinalize(2)     # => "2nd"
    #   ordinalize(1002)  # => "1002nd"
    #   ordinalize(1003)  # => "1003rd"
    def self.ordinalize(number)
      if (11..13).include?(number.to_i % 100)
        "#{number}th"
      else
        case number.to_i % 10
          when 1; "#{number}st"
          when 2; "#{number}nd"
          when 3; "#{number}rd"
          else    "#{number}th"
        end
      end
    end
  end

