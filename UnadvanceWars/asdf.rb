#!/usr/bin/env ruby
require "./field.rb"
require "rubygems"
require "rubygame"

include Rubygame

@screen = Screen.open [ 640, 480]
@field = Field.new(10,10)

# Defines a class for an example object in the game that will have a
# representation on screen ( a sprite)

class Background
  include Sprites::Sprite
  def initialize(image)
    super()
    @image = Surface.load image
    @rect = @image.make_rect()
  end
  
  def update seconds_passed
    
  end
  
  def draw on_surface
    @image.blit on_surface, @rect
  end
end

class Texts
  include Sprites::Sprite
  def initialize(text)
    super()
    TTF.setup
    point_size=18
    $font = TTF.new("data/WHITRABT.ttf", point_size)
    @image = $font.render_utf8(text, true, [0,0,0])
    @rect = @image.make_rect()
    
    @imagea = $font.render_utf8("asdf \
      and a NEL half \'NEL\' \
    of it", true, [0,0,0])
    @recta = @imagea.make_rect()
    
    #rt.topleft = [@screen.width - 8 - rt.width, @screen.height - 8 - rt.height]
    @rect.topleft =[0,0]
    @recta.topleft =[0,25]
    
  end
  
  
def update  seconds_passed
  
end


def draw  on_surface
  @image.blit on_surface, @rect
  @imagea.blit on_surface, @recta
 end
  
end

class Meanie

  # Turn this object into a sprite
  include Sprites::Sprite
  def initialize(spot)
    @i=spot
    @j=1
    # Invoking the base class constructor is important and yet easy to forget:
    super()

    # @image and @rect are expected by the Rubygame sprite code
    @image = (Surface.load "data/p1Artillery1.gif")
    #@image.blit(@image, [0,0],Rubygame::Rect.new( 0, 0, 45, 50))
    #@image = image.clip()
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @stepBool = true
    def self.j
      @j
    end
  end

  def incJ()
    @j += 1
  end

  # Animate this object.  "seconds_passed" contains the number of ( real-world)
  # seconds that have passed since the last time this object was updated and is
  # therefore useful for working out how far the object should move ( which
  # should be independent of the frame rate)
  def update  seconds_passed
    @timeSum += seconds_passed *10
    if(@timeSum >= 5)
      @timeSum = 0
      if(@stepBool)
        @image = (Surface.load "data/p1Artillery2.gif")
        # @image = Rubygame::Transform.rotozoom(@image,@angle,1,true)
      else
        @image = (Surface.load "data/p1Artillery1.gif")
      end
      @stepBool = !@stepBool
    end
    # This example makes the objects orbit around the center of the screen.
    # The objects make one orbit every 4 seconds
=begin
   puts (((rand*10).to_int).to_s)
    if ((rand*10).to_int) % 2 == 0
      @image = Surface.load "Artillery.gif"
      @rect  = Rubygame::Rect.new( 0, 0, 45, 50)
    else
      @image = Surface.load "Artillery.gif"
      @rect  = Rubygame::Rect.new( 0, 0, 45, 50)#Rubygame::Rect.new( 20, 0, @image.w - (45*6), @image.h )
    end
=end
    #@angle = ( @angle + 2*Math::PI / 1/02 * seconds_passed) % ( 2*Math::PI)
    @rect.topleft = [50*@i,50*@j]
    #@rect.topleft = [ 320 + 100 * Math.sin(@angle),240 - 100 * Math.cos(@angle)]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end
end

@clock = Clock.new
@clock.target_framerate = 60

# Ask Clock.tick() to return ClockTicked objects instead of the number of
# milliseconds that have passed:
@clock.enable_tick_events

# Create a new group of sprites so that all sprites in the group may be updated
# or drawn with a single method invocation.
@sprites = Sprites::Group.new
Sprites::UpdateGroup.extend_object @sprites


@sprites << Background.new("data/background.png")
for i in 0..9
  @sprites << Meanie.new(i)
end
@dameanie = Meanie.new(10)
@sprites <<  @dameanie
@theText = Texts.new("This is a string \n it's great! /n lets see if these work: //n \\n /\n \/n")
@sprites <<  @theText

#@sprites << @text_surface

# Load a background image and copy it to the screen
@background = Surface.load "data/background.png"
@background.blit @screen, [ 0, 0]

@event_queue = EventQueue.new
@event_queue.enable_new_style_events

def update(seconds_passed)
  @sprites.undraw @screen, @background

  # Give all of the sprites an opportunity to move themselves to a new location
  @sprites.update  seconds_passed

  # Draw all of the sprites
  @sprites.draw @screen

  @screen.flip
end

def main


  should_run = true
  while should_run do
   # p(@sprites)
    seconds_passed = @clock.tick().seconds

    puts (@event_queue)
    @event_queue.each do |event|
      case event
      when Events::QuitRequested
        should_run = false

      when Events::KeyPressed
        if(event.key == :s)
          puts (event.key)
          @sprites.at(1).incJ()
          @sprites.delete(@theText)
          @sprites.delete(@dameanie)
          if(event.key == :q)
            puts("hokay.")
            should_run = false
          end
        end
      end
    end

    #@event_queue.wait().is_a? Events::KeyPressed

    # "undraw" all of the sprites by drawing the background image at their
    # current location ( before their location has been changed by the animation)

    update(seconds_passed)

  end

end

oughtta_run = true
while oughtta_run
 # p(@sprites)
  seconds_passed = @clock.tick().seconds
  update(seconds_passed)
  puts ("welcome!")
  p("postmain")
  @event_queue.each do |event|
    case event
    when Events::QuitRequested
      oughtta_run = false
    when Events::KeyPressed
      p(event.key)
      main
    end
  end
end

