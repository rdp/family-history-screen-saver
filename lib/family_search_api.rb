$: << '.'
require 'rubygems'
require 'ruby-fs-stack'
require 'sane'
require 'andand'

require_relative 'authenticate'

$com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true
authenticate_me($com)
me = $com.familytree_v2.person :me

#suggest: pedigree_instance.parent should raise, really, shouldn't it?

def add_person person, array, level
  # add self at this level
  real_person = $com.familytree_v2.person person.id
  hash = {:name => real_person.full_name, :relation_level => level, :gender => real_person.gender}
  if birth = real_person.births[0]
    hash[:birth_place] = birth.place.andand.normalized.andand.value
    birth_date = birth.date.andand.normalized
    if birth_date
      birth_date =~ /(\d{4})/
      if $1
        hash[:birth_year] = $1.to_i
      end
    end
  end
  
  array << hash if level > 0 # don't care about yourself, right?
  add_person person.father, array, level + 1 if person.father
  add_person person.mother, array, level + 1 if person.mother
end

# like [{:name, :relation_level, :gender, :birth_place, :birth_year}, {:name...}, ... ]
def give_me_all_ancestors_as_hashes
  $com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true
  raise unless authenticate_me($com)
  my_pedigree = $com.familytree_v2.pedigree :me
  starting = my_pedigree.root
  all = [] 
  add_person(starting, all, 0)
  all
end

if $0 == __FILE__
  p give_me_all_ancestors_as_hashes
end