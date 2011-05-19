 #   flickr.photos.search

require 'rubygems'
require 'flickraw'
require 'date'

module Enumerable
  def sample
   me = to_a
   me[rand(me.length)]
  end
end

class FlickrPhoto

  @@cache = {}
  def self.get_random_photo_hash_with_url_and_title place_name, incoming_birth_year
     p 'searching', place_name, incoming_birth_year
     FlickRaw.api_key="d39c4599580b3886f7828a847020df77"
     FlickRaw.shared_secret="36f9a0945ec82822"
  
     new_b = flickr.places.find :query => place_name
      
     latitude = new_b[0]['latitude'].to_f
     longitude = new_b[0]['longitude'].to_f
     place_id = new_b[0]['place_id']    
     p 'flickr place id:' + place_name + ' ' + place_id
  
     args = {
  #      :lat => latitude, :lon => longitude,# :radius => 31, # using bbox for now
  #      :place_id => place_id
         :accuracy => 1 # needed, too, or returns like 0 things
      }
      
     radius = 3
     args[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"
      
     if rand(2) == 0 && incoming_birth_year # don't alwayas select it...
       args[:min_taken_date] = convert_year_to_timestamp (incoming_birth_year - 10).to_s
       Date.strptime('1890', '%Y')
       title = 'neighbors'
       args[:max_taken_date] = convert_year_to_timestamp (incoming_birth_year + 10).to_s
     else
      title = "#{place_name} landscape"
      args[:text] = 'landscape'
     end
     if @@cache[args]
       all = @@cache[args]
     else 
       all = flickr.photos.search args
     end
     outgoing = all.sample
     return {:url => FlickRaw.url(outgoing), :title => title + ' ' + outgoing['title']}
  end 

  def self.convert_year_to_timestamp year
     Date.strptime(year.to_s, '%Y').strftime('%Y-%m-%d %H:%M:%S')
  end
  
end

if $0 == __FILE__
  got = FlickrPhoto.get_random_photo_hash_with_url_and_title 'new brunswick', 1890
  p 'got', got
#  system("start #{got[:url]}")
  got = FlickrPhoto.get_random_photo_hash_with_url_and_title 'new brunswick', nil
  p 'got', got
#  system("start #{got[:url]}")
end
