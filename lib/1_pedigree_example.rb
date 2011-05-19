$: << '.'
require 'rubygems'
require 'ruby-fs-stack'
require 'sane'
require 'andand'

require_relative 'authenticate'

$com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true
authenticate_me($com)
me = $com.familytree_v2.person :me

# KW3B-FP5

def print_pedigree(person,level = 0)
  
  puts ' ' * level + person.full_name + " (#{person.id})"
  
  real_person = $com.familytree_v2.person person.id
  
  name = person.full_name
  if birth = real_person.births[0]
    place = birth.place.andand.normalized.andand.value
    date = birth.date.normalized
    p place, date
  end
  
  print_pedigree person.father, level+1 if person.father
  print_pedigree person.mother, level+1 if person.mother
  
end

=begin
if authenticate_me($com)
  my_pedigree = $com.familytree_v2.pedigree :me
  # my_pedigree = com.familytree_v2.pedigree 'KWZF-CFW'
  print_pedigree my_pedigree.root
end
=end

#suggest: pedigree_instance.parent should raise, really, shouldn't it?

def add_person person, array, level
  # add self at this level
  real_person = $com.familytree_v2.person person.id
  hash = {:name => real_person.full_name, :relation_level => level, :gender => real_person.gender}
  if birth = real_person.births[0]
    hash[:birth_place] = birth.place.andand.normalized.andand.value
    hash[:birth_date] = birth.date.normalized
  end
  
  array << [hash]
  add_person person.father, array, level + 1 if person.father
  add_person person.mother, array, level + 1 if person.mother
end

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