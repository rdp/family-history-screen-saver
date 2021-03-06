 #   flickr.photos.search

require 'rubygems'
require 'flickraw'
require 'date'
require 'openssl'
   OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
class FlickrPhoto

  @@cache = {}
  def self.get_random_photo_hash_with_url_and_title place_name, incoming_birth_year
     raise unless place_name
     FlickRaw.api_key="d39c4599580b3886f7828a847020df77"
     FlickRaw.shared_secret="36f9a0945ec82822"
     require 'net/http'
     uri = URI("https://api.opencagedata.com/geocode/v1/json?q=#{place_name}&key=#{File.read 'opencage_key'}")
     puts "looking up coords #{uri}"
     begin
       new2 = Net::HTTP.get(uri) # fails sometimes? LOL from their side though...
       new3=JSON.parse(new2)
       latitude = new3["results"].to_a[0]["geometry"]["lat"]
       longitude = new3["results"].to_a[0]["geometry"]["lng"]
     rescue => e
      puts "opencage failed #{e}"
    end
      
     #new_b = flickr.places.find :query => place_name # totally broken these days LOL ???
     #latitude = 10.0#new_b[0]['latitude'].to_f
     #longitude = 10.0# new_b[0]['longitude'].to_f
     #place_id = "a place id" #new_b[0]['place_id']  # unused
     #p 'flickr place id:' + place_name + ' ' + place_id
  
     args = {
  #      :lat => latitude, :lon => longitude,# :radius => 31, # using bbox for now instead
  #      :place_id => place_id
         :safe_search => 1, # try to avoid "bad" pictures-- g -rated
         :accuracy => 1 # needed, too, or returns like 0 things
      }
     if new2
       add_bbox_radius(2, args, latitude, longitude) 
     end # else don't specify any lat
     original_args = args.dup # save them away...
     if rand(2) == 0 && incoming_birth_year # somewhat random...
       args[:min_taken_date] = convert_year_to_timestamp(incoming_birth_year - 10).to_s
       title = ''
       args[:max_taken_date] = convert_year_to_timestamp(incoming_birth_year + 10).to_s
       all = do_flicker_search args
       if all.size == 0
         p 'no photos from same place, time available, choosing generic landscape of place'
         want_others = true
       end
    else
       want_others = true # landscape 1/2 the time no matter what
    end

    if want_others
      args = original_args # reset
      title = "landscape #{place_name}"
      args[:text] = "landscape #{place_name.split(',')[0]}" # seems to work great
      args[:text].gsub!(/twp/i, '') # hack hack
      # another option
      all = do_flicker_search args
      if all.size == 0
        p 'last shot...'
        args[:text] = 'landscape'
        all = do_flicker_search args
      end

    end
    
    outgoing = all.sample # randomize :P
    #p outgoing
    as_hash = {:url => FlickRaw.url(outgoing), :title => title + ' ' + outgoing['title']}
    p as_hash
    as_hash
  end

  def self.add_bbox_radius radius, to_this_hash, latitude, longitude
    to_this_hash[:bbox] = "#{longitude - radius},#{latitude - radius},#{longitude + radius},#{latitude + radius}"
  end
  
  def self.do_flicker_search args
    p 'searching', args
    if !@@cache[args]
      @@cache[args] = flickr.photos.search args # this takes like 2s, so we cache it...
	  @@cache[args] = @@cache[args].to_a
	  @@cache[args].reject!{|p| p['title'] =~ /once upon a time/i}
    end
	@@cache[args]
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
