require'java'
require 'flickr_photo' # my file

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
      pick_new_image_for_current_ancestor
      switch_image_timer = javax.swing.Timer.new(15*1000, nil)
      switch_image_timer.start
      switch_image_timer.add_action_listener do |e|
        Thread.new {  pick_new_image_for_current_ancestor } # do it in the background instead of in the one swing thread <sigh>
      end
      
    end
    
    def setup_ancestors
      # lodo just use rotate :P
      @ancestors = [{:name=>"John Pack", :relation_level=>3, :gender=>"Male", :birth_place=>"New Brunswick Canada", :birth_date=>"1809"}]
      @stats = translate_ancestor_info_to_info_strings @ancestors[0]
    end
    

    def pick_new_image_for_current_ancestor
      hash = FlickrPhoto.get_photo_hash_with_url_and_title
      p hash[:title]
      download(hash[:url], 'temp.jpg')
      @img = java.awt.Toolkit.getDefaultToolkit().createImage("temp.jpg")      
      @image_title = hash[:title]
    end
    
    def translate_ancestor_info_to_info_strings hash_stats
      new_stats = [hash_stats[:name]]
      for birth_type in [:birth_date, :birth_place]
        incoming = hash_stats[birth_type]
        new_stats << "Born #{incoming}" if incoming
      end
      new_stats << "Your #{(["Great"]*(hash_stats[:relation_level]-1)).join(' ')} Grand #{hash_stats[:gender] == 'Male' ? 'Father' : 'Mother'}"
    end
    
    # returns a java Image object of currently cached image...this might not be cpu friendly though... :P
    def get_image
      image = BufferedImage.new(1000, 300, BufferedImage::TYPE_INT_RGB);
      g = image.createGraphics()
      # by default it's all black...
      g.setColor( Color::WHITE )
      g.fillRect(0,0,1000,300)
      g.drawImage(@img, 10, 0, @img.width, [@img.height, 290].min, nil) # x, y, width, height, observer
      # now the text
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 30))
      # every 20 seconds or so, eh?
      idx = (Time.now.to_i/3) % @stats.length
      if Time.now - @start < 5
        # force beginning 0 if we're at the start of a run
        idx = 0
      end
      g.drawString(@image_title, 10, 30)
      g.drawString(@stats[idx], @img.width + 10, 100)
      g.dispose
      image
    end
    
    def paint(g)
      # it wants to float "smoothly" across the pseudo screen
      ratio = width.to_f/height()
      new_x = (Time.now.to_f*35) % (width-100)
      new_y = height - (Time.now.to_f*35) % (height-100)
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


