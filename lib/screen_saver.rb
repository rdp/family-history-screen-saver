require 'java'

require 'flickr_photo' # my file
require 'family_search_api' 
require_relative 'jruby-swing-helpers/swing_helpers'

Use_fake_ancestry = false # for demo'ing, or testing :)

if Use_fake_ancestry

  #def FamilySearchApi.give_me_random_ancestor
  #     [{:name => "Fred", :relation_level => 1, :gender => 'Male', :birth_place => 'zions national park', :birth_year => 1980}]    
  #     [{:name=>"Harriet Emily malin", :relation_level=>2, :gender=>"Female", :birth_place=>"Rockport Twp, Summit, Utah, United States", :birth_year=>1873}, {:name=>"Caroline Andersen", :relation_level=>2, :gender=>"Female", :birth_place=>"Ephraim, Sanpete, Utah, United States", :birth_year=>1878}, {:name=>"Wesley Malin Pack", :relation_level=>1, :gender=>"Male", :birth_place=>"Kamas, Summit, Utah, United States", :birth_year=>1919}, {:name=>"Guarani", :relation_level=>3, :gender=>"Male", :birth_place=>"Brazil", :birth_year=>1750}, {:name=>"coolio", :relation_level=>2, :gender=>"Male", :birth_place=>"Peru", :birth_year=>1920}, {:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845}, {:name=>"Helen Heppler", :relation_level=>1, :gender=>"Female", :birth_place=>"Richfield, Sevier, Utah, United States", :birth_year=>1909}, {:name=>"Fredette", :relation_level=>3, :gender=>"Female", :birth_place=>nil, :birth_year=>1845}]    
     fred = {:name=>"Fred", :relation_level=>2, :gender=>"Male", :birth_place=>"New York City, New York, United States", :birth_year=>1845, 
        :image_note_urls => ["http://dl.dropbox.com/u/40012820/kids.jpg"], :afn => "ABCD-1234"}
	[fred]
  #end
  def FlickrPhoto.get_random_photo_hash_with_url_and_title place, year
    out = {}
	out[:url]="./test_image.jpg"
	out[:title]="an awesome title"
	sleep 5
	out
  end
end

def download full_url, to_here
  if File.exist? full_url
    got = File.binread(full_url)
  else
    require 'open-uri'
	got = open(full_url).read
  end
  writeOut = open(to_here, "wb")
  writeOut.write(got)
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
  KeyboardFocusManager
  
  class ShowImage < JFrame
    include java.awt.event.ActionListener
    
    def initialize &block_for_single_ancestor
      super
      manager = KeyboardFocusManager.getCurrentKeyboardFocusManager
      self.defaultCloseOperation = M::JFrame::DISPOSE_ON_CLOSE 
	  manager.addKeyEventDispatcher { close }
	  @proc_to_give_me_next_ancestor = block_for_single_ancestor
      set_title("You and Your Ancestors--Living Tree--Get to Know Your Ancestors!")
      @timer = nil
      @start = Time.now
      begin
	    dialog = SwingHelpers.show_non_blocking_message_dialog "Downloading first image related to your ancestors...\nPlease wait..."
	    # get an image before starting...which is slightly prettier
        pick_new_ancestor_and_image
		dialog.close
		sleep 0.5 # let it close that thing is uhg-ly
	  rescue Exception => e
	    SwingHelpers.show_blocking_message_dialog "appears your internet connection is down, or some other problems...try again later!" + e.to_s
		raise e # kills us
	  end
	  
      switch_image_same_ancestor_timer = javax.swing.Timer.new(7*1000, nil) # switch images every 10s LODO preference
      switch_image_same_ancestor_timer.start
      switch_image_same_ancestor_timer.add_action_listener do |e|
        @download_thread.join if @download_thread # don't download 2 images at once, for slower connections...
		@download_thread = Thread.new {
          begin
            pick_and_download_new_image_for_current_ancestor @ancestor
          rescue Exception => e
		    p e.backtrace
            SwingHelpers.show_blocking_message_dialog "get new image failed?:" + e.to_s
            raise
          end
        } # do it in the background instead of in the one swing thread <sigh>
      end
      
      switch_ancestor_timer = javax.swing.Timer.new(17*1000, nil)
	  if Use_fake_ancestry
        switch_ancestor_timer = javax.swing.Timer.new(3*1000, nil)
	  end
      switch_ancestor_timer.start
      switch_ancestor_timer.add_action_listener do |e|
        Thread.new { # don't need to join since we disable the timer...
          switch_image_same_ancestor_timer.stop()
		  switch_image_same_ancestor_timer.stop()
		  @download_thread.join if @download_thread # smelly
          pick_new_ancestor_and_image
          switch_image_same_ancestor_timer.restart()
		  switch_image_same_ancestor_timer.restart()
        }
      end

      # faux full screen
      # frame.setUndecorated(true) ??
      setExtendedState(M::JFrame::MAXIMIZED_BOTH); 
      set_size(400,400) # in case them come out of maximized, have it show anything.
      
      # and finally, display it...
      self.visible=true
    end
    
	def pick_new_ancestor_and_image
      birth_place = nil
      until birth_place
        ancestor = @proc_to_give_me_next_ancestor.call
        p 'doing a next/different ancestor' + ancestor.inspect
        birth_place = ancestor[:birth_place]
      end
      stats = translate_ancestor_info_to_info_strings ancestor
      name = stats.shift
	  pick_and_download_new_image_for_current_ancestor ancestor
 	  @ancestor = ancestor
	  @stats = stats
	  @name = name
 	end
	
    def pick_and_download_new_image_for_current_ancestor ancestor
      if(ancestor[:image_note_urls].length > 0 && (rand(2) == 0))
        url = ancestor[:image_note_urls].sample
        p 'doing image from notes', url
        new_title = url.split('/')[-1].split('.')[0..-2].join('.')
        image_title_prefix = ''
      else
        hash = FlickrPhoto.get_random_photo_hash_with_url_and_title ancestor[:birth_place], ancestor[:birth_year]
        p 'doing flickr', hash
        url = hash[:url]
        new_title = hash[:title]
        image_title_prefix = "Photo from near #{ancestor[:name].split.first}'s birthplace and birthyear"
		if new_title =~ /landscape/i # LODO more accuracy
		  image_title_prefix += " (present day)"
		end
      end
      begin
	    download(url, 'temp.jpg')
	  rescue Exception => e	   
	    p 'unable to download next image?' + e.to_s + e.backtrace.inspect
		return # early
	  end
      @img = java.awt.Toolkit.getDefaultToolkit().createImage("temp.jpg")      
	  @image_title_prefix=image_title_prefix # set them post download LODO ugly
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
	  if generations_from_you
          if generations_from_you == 0
		    output = 'Yourself' 
		  else
			  output = "Your "
			  if generations_from_you >= 3
				output += (["Great "] * (generations_from_you - 2)).join('')
			  end
			  if generations_from_you >= 2
				output += " Grand"
			  end
			  
			  if hash_stats[:gender] == 'Male'
			    if hash_stats[:non_direct]
				  output += "uncle"
				else
				  output += "father"
				end
			  else
			    if hash_stats[:non_direct]
				  output += "aunt"
				else
				  output += "mother"
				end
			  end
		  end
	  else
	    output = 'Ancestor or Relative' # TODO more here? -- could be "just relative" since the gedcom parser didn't find it...
	  end
      new_stats << output
    end
    
    # returns a java Image object from currently cached image...this currently might not be too cpu friendly though... :P
    def get_floater_image
      # LODO cache this method...if expensive :P
	  image_height = 350
      floater_height = image_height + 200
	  floater_width = 1000
      
      image = BufferedImage.new(floater_width, floater_height, BufferedImage::TYPE_INT_RGB);
      
      g = image.createGraphics()
      # by default it's all black...I think.
      g.setColor( Color::WHITE )
      g.fillRect(0,0,floater_width,floater_height)
      unless @img
        p 'image not downloaded yet, perhaps? -- not drawing it...'
        return image
      end
      image_height = [@img.height, image_height].min # LODO am I getting full res images?
      g.setColor( Color::BLACK )
      g.setFont(Font.new("Lucida Bright", Font::ITALIC, 30))
      g.drawString(@image_title_prefix, 30, 60)
      g.drawString(@image_title, 30, image_height+120)
	  
      g.drawImage(@img, 10, 90, @img.width, image_height, nil) # x, y, width, height, observer LODO does this stretch things weirdly?
      # now the text around the image
      # switch every 20 seconds or so, eh?
      idx = (Time.now.to_i/3) % @stats.length
      if Time.now - @start < 5
        # force beginning 0 if we're at the start of a run
        idx = 0
      end
      g.drawString(@name, @img.width + 30, 130)
      g.drawString(@stats[idx], @img.width + 30, 180)
      g.dispose
      image
    end
    
    def paint(g)
      # it wants to float "smoothly" across the (pseudo) screen
      ratio = width().to_f/height()
      new_x = (Time.now.to_f*35) % (width-700) # not let it go too far right
	  scrolling_speed = 25 # bigger is faster movement
      new_y = (height() - (Time.now.to_f*scrolling_speed)) % (height()-350) # don't go too far down
      g.translate(new_x, new_y)
      g.rotate(0.1, 0.0, 0.0)
      g.drawImage(get_floater_image,0,0,self)
      unless @timer
        duration = 0.03*1000
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
