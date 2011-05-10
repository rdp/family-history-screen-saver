 #   flickr.photos.search
 require 'rubygems'
 require 'flickraw'

 FlickRaw.api_key="d39c4599580b3886f7828a847020df77"
 FlickRaw.shared_secret="36f9a0945ec82822"

 list   = flickr.photos.getRecent

 id     = list[0].id
 secret = list[0].secret
=begin
 info = flickr.photos.getInfo :photo_id => id, :secret => secret

 p info.title           # => "PICT986"
 p info.dates.taken     # => "2006-07-06 15:16:18"

 sizes = flickr.photos.getSizes :photo_id => id
 p sizes
 original = sizes.find {|s| s.label == 'Original' }
 # p original       # => "800"

=end

    p 'begin new'

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
    
#    args[:min_taken_date] = '1890-01-01 00:00:00'
    
#    args[:max_taken_date] = '1910-01-01 00:00:00'
    args[:text] = 'landscape'
    args[:per_page] = 20

   # requires min_taken_date or it will just give the past 12 hours...

    info = flickr.photos.search args
    p info.length
    title = info[0]['title']
    #p info[0]   
    info.each{|i|
      url = FlickRaw.url i
      puts url
      system("start #{url}") if ARGV.index('--go')
    }
  