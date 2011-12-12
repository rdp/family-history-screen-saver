require 'java'

# bundled gems...
for dir in Dir[File.dirname(__FILE__) + '/../vendor/gems/**/lib'] do
  $: << File.expand_path(dir)
end
$: << './lib'
require 'sane'

require 'flickr_photo' # my file
require 'family_search_api' 
require_relative 'jruby-swing-helpers/swing_helpers'

use_fake_ancestry = false # for demo'ing, or testing :)

if use_fake_ancestry

  def give_me_all_ancestors_as_hashes    
  #     [{:name => "Fred", :relation_level => 1, :gender => 'Male', :birth_place => 'zions national park', :birth_year => 1980}]    
  #     [{:name=>"Harriet Emily malin", :relation_level=>2, :gender=>"Female", :birth_place=>"Rockport Twp, Summit, Utah, United States", :birth_year=>1873}, {:name=>"Caroline Andersen", :relation_level=>2, :gender=>"Female", :birth_place=>"Ephraim, Sanpete, Utah, United States", :birth_year=>1878}, {:name=>"Wesley Malin Pack", :relation_level=>1, :gender=>"Male", :birth_place=>"Kamas, Summit, Utah, United States", :birth_year=>1919}, {:name=>"Guarani", :relation_level=>3, :gender=>"Male", :birth_place=>"Brazil", :birth_year=>1750}, {:name=>"coolio", :relation_level=>2, :gender=>"Male", :birth_place=>"Peru", :birth_year=>1920}, {:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845}, {:name=>"Helen Heppler", :relation_level=>1, :gender=>"Female", :birth_place=>"Richfield, Sevier, Utah, United States", :birth_year=>1909}, {:name=>"Fredette", :relation_level=>3, :gender=>"Female", :birth_place=>nil, :birth_year=>1845}]    
     [{:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}]
  end

end

def download full_url, to_here
  require 'open-uri'
  writeOut = open(to_here, "wb")
  writeOut.write(open(full_url).read)
  writeOut.close
end

module M
  include_package "javax.swing"
  include_package "java.awt"
  include_package "java.awt.image" # BufferedImage
  include_package "javax.awt"
  include_package "javax.net"
  BufferedImage # boo http://jira.codehaus.org/browse/JRUBY-5107
  Font
  Color
  RenderingHints
  
  class ShowImage < JFrame
    include java.awt.event.ActionListener
    
    def initialize
      super
      set_title("You and Your Ancestors--Living Tree--Get to Know Your Ancestors lives!")
      @timer = nil
      @start = Time.now
      setup_ancestors
      pick_new_ancestor
      
      begin
        pick_and_download_new_image_for_current_ancestor 
      rescue => e
        p 'download failed?' + e.to_s # ignore, so basically re-use the old image
      end
      switch_image_same_ancestor_timer = javax.swing.Timer.new(5*1000, nil)
      switch_image_same_ancestor_timer.start
      switch_image_same_ancestor_timer.add_action_listener do |e|
        Thread.new { 
          begin
            pick_and_download_new_image_for_current_ancestor 
          rescue Exception => e
            SwingHelpers.show_blocking_message_dialog "flickr failed?:" + e.to_s
            raise
          end
        } # do it in the background instead of in the one swing thread <sigh>
      end
      
      switch_ancestor_timer = javax.swing.Timer.new(17*1000, nil)
      switch_ancestor_timer.start
      switch_ancestor_timer.add_action_listener do |e|
        Thread.new {
          pick_new_ancestor
          switch_image_same_ancestor_timer.restart()
          pick_and_download_new_image_for_current_ancestor
          switch_image_same_ancestor_timer.restart()
        }
      end
    end
    
    def setup_ancestors
      p 'downloading your ancestors\' information from new familysearch...'
      @ancestors = give_me_all_ancestors_as_hashes
      p 'done, here are your ancestors:', @ancestors
      @ancestors.shuffle!
      raise 'unable to find any ancestors within new familysearch for you?' unless @ancestors.length > 0
    end
    
    def pick_new_ancestor
      # rotate...
      birth_place = nil
      until birth_place
        @ancestor = @ancestors.shift
        p 'doing a different ancestor' + @ancestor.inspect
        @ancestors << @ancestor
        birth_place = @ancestor[:birth_place]
      end
      @stats = translate_ancestor_info_to_info_strings @ancestor
      @name = @stats.shift
      # too annoying, but does preserve continuity... @img = nil
    end
    
    def pick_and_download_new_image_for_current_ancestor
      if(@ancestor[:image_note_urls].length > 0 && (rand(2) == 0))
        url = @ancestor[:image_note_urls].sample
        p 'doing local', url
        new_title = url.split('/')[-1].split('.')[0..-2].join('.')
        @image_title_prefix = ''
      else
        hash = FlickrPhoto.get_random_photo_hash_with_url_and_title @ancestor[:birth_place], @ancestor[:birth_year]
        p 'doing flickr', hash
        url = hash[:url]
        new_title = hash[:title]
        @image_title_prefix = 'Photo from near their birth:'
      end
      download(url, 'temp.jpg')
      @img = java.awt.Toolkit.getDefaultToolkit().createImage("temp.jpg")      
      @image_title = new_title
    end
    
    def translate_ancestor_info_to_info_strings hash_stats
      new_stats = [hash_stats[:name]]
      for birth_type in [:birth_year, :birth_place]
        incoming = hash_stats[birth_type]
        new_stats << "Born #{incoming}" if incoming
      end
      
      # 0 is you, 1 is father
      generations_from_you = hash_stats[:relation_level]
      output = "Your "
      if generations_from_you >= 3
        output += (["Great "] * (generations_from_you - 2)).join('')
      end
      if generations_from_you >= 2
        output += " Grand"
      end
      
      if hash_stats[:gender] == 'Male'
        output += "father"
      else
        output += "mother"
      end
      output = 'Yourself' if generations_from_you == 0
      new_stats << output
    end
    
    # returns a java Image object from currently cached image...this currently might not be too cpu friendly though... :P
    def get_floater_image
      # LODO cache it...
      floater_height = 450
      
      image = BufferedImage.new(1000, floater_height, BufferedImage::TYPE_INT_RGB);
      
      g = image.createGraphics()
      # by default it's all black...I think.
      g.setColor( Color::WHITE )
      g.fillRect(0,0,1000,floater_height)
      unless @img
        p 'image not downloaded yet, perhaps? -- not drawing it...'
        return image
      end
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 30))
      g.drawString(@image_title_prefix + ' ' + @image_title, 30, 30)
      image_height = [@img.height, floater_height - 90].min
      g.drawImage(@img, 10, 60, @img.width, image_height, nil) # x, y, width, height, observer
      # now the text around it
      # switch every 20 seconds or so, eh?
      idx = (Time.now.to_i/3) % @stats.length
      if Time.now - @start < 5
        # force beginning 0 if we're at the start of a run
        idx = 0
      end
      g.drawString(@name, @img.width + 30, 100)
      g.drawString(@stats[idx], @img.width + 10, 150)
      g.dispose
      image
    end
    
    def paint(g)
      # it wants to float "smoothly" across the pseudo screen
      ratio = width.to_f/height()
      new_x = (Time.now.to_f*35) % (width-700) # not let it go too far right
      new_y = (height() - (Time.now.to_f*35)) % (height-150)
      g.translate(new_x, new_y)
      g.rotate(0.2, 0, 0)
      g.drawImage(get_floater_image,0,0,self)
      unless @timer
        duration = 0.02*1000
        @timer = javax.swing.Timer.new(duration, self)
        @timer.start
      end
    end
    
    def actionPerformed(e)
       # timer fired
       self.repaint
    end
  end
  
end
