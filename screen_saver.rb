require'java'
require 'flickr_photo'

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
      pick_new_image
      @switch_image_timer = javax.swing.Timer.new(0.02*1000, nil)
      @switch_image_timer.start
    end

    def pick_new_image
      @img= java.awt.Toolkit.getDefaultToolkit().getImage("johnpack1.jpg")      
      hash = FlickrPhoto.get_photo_hash_with_url_and_title
      p hash[:title]
      download(hash[:url], 'temp.jpg')
      @img=java.awt.Toolkit.getDefaultToolkit().getImage("temp.jpg")      
      @image_title = hash[:title]
    end

    Stats = ["John Pack", "Born 1809", "Born New Brunswick Canada", "Your Great Grand Father"]

    def get_image
      image = BufferedImage.new(1000, 300, BufferedImage::TYPE_INT_RGB);
      g = image.createGraphics()
      # by default it's all black...
      g.setColor( Color::WHITE )
      g.fillRect(0,0,1000,300)
      g.drawImage(@img, 0, 0, @img.width, @img.height, nil) # failure here is ok now...
      # now the text
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 30))
      # every 20 seconds or so, eh?
      idx = (Time.now.to_i/3) % Stats.length
      if Time.now - @start < 5
        idx = 0
        # force beginning 0 if we're at the start of a run
      end
      g.drawString(@image_title, 10, 30)
      g.drawString(Stats[idx], @img.width + 10, 100)
      g.dispose
      image
    end
    
    def paint(g)
      # it wants to float "smoothly" across the pseudo screen
      ratio = width.to_f/height
      new_width = (Time.now.to_f*35) % (width)
      ratio*new_height = height - (Time.now.to_f*35) % (height)
      g.translate(new_width, new_height)
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

def dbg
  require 'rubygems'
  require 'ruby-debug'
  debugger
end

alias _dbg dbg

frame = M::ShowImage.new
frame.defaultCloseOperation = M::JFrame::EXIT_ON_CLOSE

# full screen
#frame.setUndecorated(true)
frame.setExtendedState(M::JFrame::MAXIMIZED_BOTH); 

# and visible
frame.visible=true


