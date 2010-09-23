require'java'
def dbg
  require 'rubygems'
  require 'ruby-debug'
  debugger
end
alias _dbg dbg

module M
include_package "javax.swing"
import "java.awt.image.BufferedImage" # odd
include_package "javax.awt"
include_package "javax.net"
import "java.awt.Font"
import "java.awt.Color"

  class ShowImage < JFrame
    include java.awt.event.ActionListener
    
    def initialize
      @img= java.awt.Toolkit.getDefaultToolkit().getImage("c:/dev/ruby/johnpack1.jpg")      
      @timer = nil
    end

    Stats = ["Born 1809", "New Brunswick, Canada", "Your Grandfather"]

    def get_image
      image = BufferedImage.new(1000, 300, BufferedImage::TYPE_INT_RGB);
      g = image.createGraphics()
      # by default it's all black...
      g.setColor( Color::WHITE )
      g.fillRect(0,0,1000,300)
      raise unless g.drawImage(@img, 0, 0, @img.width, @img.height, nil)
      # now the text
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 60))
      g.drawString(Stats[Time.now.to_i % Stats.length], 250, 100)
      g.dispose
      image
    end
    
    def paint(g)
    
      # it wants to float "smoothly" across the screen
      
      ratio = width.to_f/height
      
      new_width = (Time.now.to_f*50) % width
      ratio*new_height = height - (Time.now.to_f*50) % height      
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

frame = M::ShowImage.new
frame.defaultCloseOperation = M::JFrame::EXIT_ON_CLOSE

# full screen
#frame.setUndecorated(true)
frame.setExtendedState(M::JFrame::MAXIMIZED_BOTH); 

# and visible
frame.visible=true


