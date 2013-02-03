require "rubygems"
require "rubygame"

include Rubygame

class Sea

  include Sprites::Sprite
  def initialize(space)
    super()
    @imageName = "Sea"
    @timeSum = 0
    @stepBool = true

    @defence = 1
    @movement = 1
    @space = space
    @image = (Surface.load @imageName + "1.gif")
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
    @timeSum += seconds_passed *10
    if(@timeSum >= 5)
      @timeSum = 0
      if(@stepBool)
        @image = (Surface.load(@imageName + "2.gif"))
      else
        @image = (Surface.load(@imageName + "1.gif"))
      end
      @stepBool = !@stepBool
    end
    @rect.topleft = [50*@x,50*@y]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end