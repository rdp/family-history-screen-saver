 #   flickr.photos.search

 require 'rubygems'
 require 'flickraw'

module Enumerable
  def sample
   me = to_a
   me[rand(me.length)]
  end
end

class FlickrPhoto

  def self.get_photo_hash_with_url_and_title


 FlickRaw.api_key="d39c4599580b3886f7828a847020df77"
 FlickRaw.shared_secret="36f9a0945ec82822"

    new_b = flickr.places.find :query => "new brunswick" # happiness!
    latitude = new_b[0]['latitude'].to_f
    longitude = new_b[0]['longitude'].to_f
    p new_b[0]['latitude']
    place_id = new_b[0]['place_id']    
    p place_id

    p 'begin flickr.photos.search' # place is is way too messed up
    args = {
#      :lat => latitude, :lon => longitude,# :radius => 31,
#      :place_id => place_id
        :accuracy => 1
    }
    
    args[:bbox] = "1.00140103605456,51.35108866688886,1.040175061070918,51.3681866301438"
    
    radius = 3
    args[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"
    
   # requires min_taken_date or it will just give the past 12 hours...
    args[:min_taken_date] = '1890-01-01 00:00:00'
   if rand(2) == 0  # random
     title = 'neighbors'
     args[:max_taken_date] = '1910-01-01 00:00:00'
   else
    title = 'new brunswick landscape'
    args[:text] = 'landscape'
   end

    info = flickr.photos.search args
    p info.to_a.length
    title = info[0]['title']
    outgoing = info.sample
    return {:url => FlickRaw.url(outgoing), :title => title + ' ' + outgoing['title']}
 end 

end

if $0 == __FILE__
  p FlickrPhoto.get_photo_hash_with_url_and_title
end
