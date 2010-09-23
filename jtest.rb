require'java'
def dbg
  require 'rubygems'
  require 'ruby-debug'
  debugger
end

module M
include_package "javax.swing"
include_package "javax.awt"
include_package "javax.net"

  class ShowImage < JFrame
    include java.awt.event.ActionListener
    
    def initialize
      @img= java.awt.Toolkit.getDefaultToolkit().getImage("c:/dev/ruby/johnpack1.jpg")      
      @timer = nil
    end
    
    def paint(g)
    
      # it wants to float "smoothly" across the screen
      
      ratio = width.to_f/height
      
      new_width = (Time.now.to_f*50) % width
      ratio*new_height = height - (Time.now.to_f*50) % height      
      g.translate(new_width, new_height)
      g.rotate(0.3, 0, 0)
      #dbg
      g.drawString("this is totally awesome", 20, 20)
      g.drawImage(@img,0,0,self)
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


