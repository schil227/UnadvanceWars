require "rubygems"
require "rubygame"

include Rubygame

class Mountain

  include Sprites::Sprite
  def initialize(space)
    super()
    @defence = 4
    @movement = 3
    @space = space
    @image = (Surface.load "data/mountain.gif")
    @rect = @image.make_rect
    @x = @space.y
    @y = @space.x
    
    def self.movement
      @movement
    end
    
    def self.defence
      @defence
    end
    
  end

  def update  seconds_passed
    @rect.topleft = [50*@x,50*@y]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end
  

end