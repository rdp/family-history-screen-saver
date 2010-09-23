require'java'

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
      new_width = (Time.now.to_f*50) % width
      new_height = (Time.now.to_f*50) % height
      g.drawImage(@img,new_width,new_height,self)
      #//Graphics2D g2d=(Graphics2D)g; 
      #g2d.translate(170, 0)
      #g2d.rotate(1)
      #g2d.drawImage(, 0, 0, 200, 200, this)    
      unless @timer
        duration = 0.02*1000
        @timer = javax.swing.Timer.new(duration, self)
        @timer.start
      end
    end
    
     def actionPerformed(e)
       # timer fired
       
      #puts 'timer'
       self.repaint
     end
    
  end
  
end

frame = M::ShowImage.new
frame.defaultCloseOperation = M::JFrame::EXIT_ON_CLOSE

# full screen
frame.setUndecorated(true)
frame.setExtendedState(M::JFrame::MAXIMIZED_BOTH); 

# and visible
frame.visible=true


