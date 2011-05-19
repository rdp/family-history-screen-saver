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

  def self.get_photo_hash_with_url_and_title place_name = 'new brunswick', incoming_start_year = '1890', incoming_end_year = '1910'

    FlickRaw.api_key="d39c4599580b3886f7828a847020df77"
    FlickRaw.shared_secret="36f9a0945ec82822"

    new_b = flickr.places.find :query => place_name
    
    latitude = new_b[0]['latitude'].to_f
    longitude = new_b[0]['longitude'].to_f
    place_id = new_b[0]['place_id']    
    p 'flickr place id:' + place_id

    args = {
#      :lat => latitude, :lon => longitude,# :radius => 31, # using bbox for now
#      :place_id => place_id
        :accuracy => 1 # needed, too, or returns like 0 things
    }
    
    radius = 3
    args[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"
    
   # requires min_taken_date or it will just give the past 12 hours...
   args[:min_taken_date] = convert_year_to_timestamp incoming_start_year
   Date.strptime('1890', '%Y')
  
   if rand(2) == 0  # random
     title = 'neighbors'
     args[:max_taken_date] = convert_year_to_timestamp incoming_end_year
   else
    title = 'new brunswick landscape'
    args[:text] = 'landscape'
   end
    info = flickr.photos.search args
    outgoing = info.sample
    return {:url => FlickRaw.url(outgoing), :title => title + ' ' + outgoing['title']}
  end 

  def self.convert_year_to_timestamp year
     Date.strptime(year, '%Y').strftime('%Y-%m-%d %H:%M:%S')
  end

end

if $0 == __FILE__
  got = FlickrPhoto.get_photo_hash_with_url_and_title
  system("start #{got[:url]}")
end
