require "rubygems"
require "rubygame"

include Rubygame

class City

  include Sprites::Sprite
  def initialize(space)
    super()
    @occoupiedPlayer = nil
    @cityLevel = 20
    @defence = 3
    @movement = 1
    @space = space
    @image = (Surface.load "data/city.gif")
    @rect = @image.make_rect
    @x = @space.y
    @y = @space.x
    def self.occoupiedPlayer
      @occoupiedPlayer
    end

    def self.movement
      @movement
    end

    def self.defence
      @defence
    end

  end

  def setOccoupiedPlayer(playerNum)
    case (playerNum)
    when 1
      @imageName = "data/p1City.gif"
    when 2
      @imageName = "data/p2City.gif"
    when 3
      @imageName = "data/p3City.gif"
    when 4
      @imageName = "data/p4City.gif"
    else
      @imageName = "data/city.gif"
    end
  end

  def conquer(unit)
    @cityLevel -= unit.health
    if(@cityLevel < 1)
      @cityLevel = 20
      setOccoupiedPlayer(unit.commander)
    end
  end

  def setOccoupiedPlayer(commander)
    @occoupiedPlayer = commander
    @image = (Surface.load("p"+commander.playerNum.to_s+"city.gif"))
  end

  def update  seconds_passed
    @rect.topleft = [50*@x,50*@y]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end