$: << '.'
require 'rubygems'
require 'ruby-fs-stack'
require 'andand'

require 'authenticate'

$com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true
authenticate_me($com)
me = $com.familytree_v2.person :me

# KW3B-FP5 is me...

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

if authenticate_me($com)
  my_pedigree = $com.familytree_v2.pedigree :me
  #  my_pedigree = com.familytree_v2.pedigree 'KWZF-CFW'
  print_pedigree my_pedigree.root
end