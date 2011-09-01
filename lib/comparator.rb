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
        if best_ancestor_relat > ancestor[:relation_level]
          # we have a winner
          best_ancestor = ancestor
          best_ancestor_relat = ancestor[:relation_level]
        end
      end
    }
    
    if best_ancestor_relat == 2
      'cousins'
    elsif best_ancestor_relat == 0
      'self'
    elsif best_ancestor_relat == 1
      'brother/sister'
    else
      'no match--you\'re not related!'
    end
    
  end
  
  def self.hash_by_afn x_ancestors
    by_afn = {}
    x_ancestors.each{|ancestor|
      by_afn[ancestor[:afn]] = ancestor
    }
    by_afn
  end
    
    
end