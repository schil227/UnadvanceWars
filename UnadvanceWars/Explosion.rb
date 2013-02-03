require "rubygems"
require "rubygame"

include Rubygame

class Explosion
  include Sprites::Sprite
  def initialize(x, y)
    super()
    @x = y
    @y = x
    @stepX=1
    @imageName = "explosion"
    @image = (Surface.load(@imageName + @stepX.to_s + ".gif"))
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @isDone = false
    
    def self.isDone
      @isdone
    end
  end
  
  def update(seconds_passed)
    @timeSum += seconds_passed *10
      if(@timeSum >= 1 && @stepX < 7)
        @stepX+=1
        @timeSum = 0
        @image = (Surface.load(@imageName + @stepX.to_s + ".gif"))
      elsif(@stepX >= 7)
        @isDone = true
      end
      @rect.topleft = [50*@y,50*@x]
  end
  
    def draw  on_surface
      @image.blit  on_surface, @rect
    end

end