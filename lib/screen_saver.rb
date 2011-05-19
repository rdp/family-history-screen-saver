require'java'
require 'flickr_photo' # my file
require '1_pedigree_example' 

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
  
  class ShowImage < JFrame
    include java.awt.event.ActionListener
    
    def initialize
      super
      @timer = nil
      @start = Time.now
      setup_ancestors
      pick_new_ancestor
      
      pick_and_download_new_image_for_current_ancestor
      switch_image_timer = javax.swing.Timer.new(10*1000, nil)
      switch_image_timer.start
      switch_image_timer.add_action_listener do |e|
        Thread.new { pick_and_download_new_image_for_current_ancestor } # do it in the background instead of in the one swing thread <sigh>
      end
      
      switch_ancestor_timer = javax.swing.Timer.new(19*1000, nil)
      switch_ancestor_timer.start
      switch_ancestor_timer.add_action_listener do |e|
        pick_new_ancestor
        p 'picked new ancestor, downloading image'
        switch_image_timer.restart()
        pick_and_download_new_image_for_current_ancestor
        p 'downloaded new image for him'
        switch_image_timer.restart()
      end

    end
    
    def setup_ancestors
      p 'computing your ancestors...'
      @ancestors = give_me_all_ancestors_as_hashes.shuffle
    end
    
    def pick_new_ancestor
      # rotate
      birth_place = nil
      until birth_place
        @ancestor = @ancestors.shift
        p 'doing next ancestor' + @ancestor.inspect
        @ancestors << @ancestor
        birth_place = @ancestor[:birth_place]
      end
      @stats = translate_ancestor_info_to_info_strings @ancestor
      @name = @stats.shift
    end
    
    def pick_and_download_new_image_for_current_ancestor
      hash = FlickrPhoto.get_random_photo_hash_with_url_and_title @ancestor[:birth_place], @ancestor[:birth_year]
      download(hash[:url], 'temp.jpg')
      @img = java.awt.Toolkit.getDefaultToolkit().createImage("temp.jpg")      
      @image_title = hash[:title]
    end
    
    def translate_ancestor_info_to_info_strings hash_stats
      new_stats = [hash_stats[:name]]
      for birth_type in [:birth_year, :birth_place]
        incoming = hash_stats[birth_type]
        new_stats << "Born #{incoming}" if incoming
      end
      number_of_greats = hash_stats[:relation_level]-2
      number_of_greats = 0 if number_of_greats < 0
      output = "Your "
      if number_of_greats > 1
        output += (["Great "] * number_of_greats).join('')
      end
      if number_of_greats > 0
        output += " Grand"
      end
      if hash_stats[:gender] == 'Male'
        output += "father"
      else
        output += "mother"
      end
      new_stats << output
    end
    
    # returns a java Image object of currently cached image...this might not be cpu friendly though... :P
    def get_image
      image = BufferedImage.new(1000, 350, BufferedImage::TYPE_INT_RGB);
      g = image.createGraphics()
      # by default it's all black...
      g.setColor( Color::WHITE )
      g.fillRect(0,0,1000,350)
      image_height = [@img.height, 290].min
      g.drawImage(@img, 10, 0, @img.width, image_height, nil) # x, y, width, height, observer
      # now the text
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 30))
      # every 20 seconds or so, eh?
      idx = (Time.now.to_i/3) % @stats.length
      if Time.now - @start < 5
        # force beginning 0 if we're at the start of a run
        idx = 0
      end
      g.drawString(@image_title, 30, image_height + 50)
      g.drawString(@name, @img.width + 10, 100)
      g.drawString(@stats[idx], @img.width + 10, 150)
      g.dispose
      image
    end
    
    def paint(g)
      # it wants to float "smoothly" across the pseudo screen
      ratio = width.to_f/height()
      new_x = (Time.now.to_f*35) % (width-550) # not go off the page too far
      new_y = (height - (Time.now.to_f*35)) % (height-150)
      g.translate(new_x, new_y)
      g.rotate(0.3, 0, 0)
      g.drawImage(get_image,0,0,self)
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

frame = M::ShowImage.new
frame.defaultCloseOperation = M::JFrame::EXIT_ON_CLOSE

# faux full screen
# frame.setUndecorated(true) ??
frame.setExtendedState(M::JFrame::MAXIMIZED_BOTH); 

# and visible
frame.visible=true


