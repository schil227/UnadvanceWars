require "rubygems"
require "rubygame"

include Rubygame

class Cursor
  include Sprites::Sprite
  def initialize(space)
    @space = space
    @image = (Surface.load "data/cursor.gif")
    @rect = @image.make_rect
    @x = @space.x
    @y = @space.y
  end

  def update  seconds_passed
    @rect.topleft = [45*@x,50*@y]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end