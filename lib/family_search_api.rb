require 'sane' # require_relative
require 'ruby-fs-stack'
require 'andand'
require_relative 'jruby-swing-helpers/swing_helpers'
require __DIR__ + "/deps.jar"
require 'authenticate'

$com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true

def add_person person, array, level
  if array.length > 20
    p 'done downloading the first 20 people in your ancestry tree, stopping for now, for demo sake...'
    return
  end
  $stdout.print '.'
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
  hash[:image_note_urls] = get_me_all_urls_in_the_notes_for_this_person person.id
  hash[:afn] = person.id
  array << hash if level >= 0 # include yourself, since you're a real person :)
  add_person person.father, array, level + 1 if person.father
  add_person person.mother, array, level + 1 if person.mother
end

# utilities for flattening the stuff familysearch gives us

def flatten_object something
   if something.is_a? Hash
     super_flatten_hash(something)
   elsif something.is_a? Array
     super_flatten_array(something)
   else
     something
   end
end

def super_flatten_array array
  array.map{|element|
    flatten_object element
  }.flatten  
end

def super_flatten_hash hash
  outgoing = hash.to_a.flatten
  outgoing.map{|k, v|
    [flatten_object(k), flatten_object(v)]
  }.flatten
end

def get_me_all_urls_in_the_notes_for_this_person person_id
  me = $com.familytree_v2.person person_id, :personas => 'all'
  urls = []
  me.personas.personas.each{|persona|
    persona_retrieved = $com.get("/familytree/v2/persona/#{person_id}?session=#{$com.session}&properties=all&names=all&events=all&characteristics=all&ordinances=all&identifiers=all&submitters=all&citations=all&notes=all&contributors=all&exists=all")
    parsed = JSON.parse persona_retrieved.body
    all_persona_stuff = flatten_object(parsed)
    hashes = all_persona_stuff.select{|element| element.is_a?(String) && element =~ /\w{74}/} # some are citations, some are notes...
    for note_hash in hashes
       begin
        yo = $com.get("/familytree/v2/note/#{note_hash}?sessionId=#{$com.session}")
        p yo.body.scan(URL_MATCHER).map(&:first)
        urls += yo.body.scan(URL_MATCHER).map(&:first)
       rescue RubyFsStack::NotFound => ignore
       end
    end
  }
  urls
end

module FamilySearchApi
  URL_MATCHER = /(((http|ftp|https):\/{2})+(([0-9a-z_-]+\.)+(aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cu|cv|cx|cy|cz|cz|de|dj|dk|dm|do|dz|ec|ee|eg|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mn|mn|mo|mp|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|nom|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ra|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|sj|sk|sl|sm|sn|so|sr|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw|arpa)(:[0-9]+)?((\/([~0-9a-zA-Z\#\+\%@\.\/_-]+))?(\?[0-9a-zA-Z\+\%@\/&\[\];=_-]+)?)?))\b/i

  def self.warmup
    @@ancestors ||= give_me_all_ancestors_as_hashes
  end
  
  def self.give_me_random_ancestor
    @@ancestors.sample
  end

# like [{:name, :relation_level, :gender, :birth_place, :birth_year}, {:name...}, ... ]
  def self.give_me_all_ancestors_as_hashes
    $com = FsCommunicator.new :domain => 'http://www.dev.usys.org', :handle_throttling => true
    if File.exist? 'test_user'
      user = File.read('test_user')
      pass = File.read('test_pass')
    else
      user = SwingHelpers.get_user_input('enter your *dev* familysearch login:')
      pass = SwingHelpers.get_password_input('Enter your password for the same:')
    end
    
    begin
      authenticate_me($com, user, pass)
    rescue RubyFsStack::Unauthorized, Errno::EAGAIN => e
      SwingHelpers.show_blocking_message_dialog "login failed!" + e.to_s
      raise
    end
    puts "login succeeded! #{user}"
    my_pedigree = $com.familytree_v2.pedigree :me
    # my_pedigree = com.familytree_v2.pedigree 'KWZF-CFW'
    starting = my_pedigree.root
    all = []
    add_person(starting, all, 0)
    all
  end

end

if $0 == __FILE__
  p FamilySearch.give_me_all_ancestors_as_hashes
end