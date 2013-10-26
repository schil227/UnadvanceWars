require "rubygems"
require "rubygame"

include Rubygame

class Artillery

  include Sprites::Sprite
  def initialize(x, y, playerNum)

    super()
    case (playerNum)
    when 1
      @imageName = "data/p1Artillery"
    when 2
      @imageName = "data/p2Artillery"
    when 3
      @imageName = "data/p3Artillery"
    when 4
      @imageName = "data/p4Artillery"
    end

    @image = (Surface.load(@imageName + "1.gif"))
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @stepBool = true

    @health = 10
    @power = 10*(@health * 0.1)
    @attackRange = [2,3]
    @movement = 6
    @symb = 'a'
    @x = x
    @y = y
    @isDirect = false;
    @isDestroyed = false;
    @hasMoved = false
    @commander = nil
    @attackTable = {'i' => 0.90, 'm' => 0.85, 'r' => 0.80, 't' => 0.70, 'M' => 0.45, 'p' => 0.70, 'a' => 0.75, 'R' => 0.80, 'A' => 0.75, 's' => 0.80, 'L' => 0.55, 'C'=> 0.65, 'S' =>0.60, 'B' => 0.40}
    @ammo = 5 
	 @maxammo = 5
    @fuel = 60 
	 @maxFuel = 60
    @isFlying = false
    @isSailing = false
    @cost = 6000
    @unitCommands = ['attack','wait']

    def self.unitCommands
      @unitCommands
    end

    def self.cost
      @cost
    end

    def self.isSailing
      @isSailing
    end

    def self.isFlying
      @isFlying
    end

    def self.fuel
      @fuel
    end

	 def self.maxFuel
      @maxFuel
    end

    def self.ammo
      @ammo
    end

	 def self.maxAmmo
      @maxAmmo
    end

    def self.attackTable
      @attackTable
    end

    def self.commander
      @commander
    end

    def self.hasMoved
      @hasMoved
    end

    def self.health
      @health
    end

    def self.power
      @power
    end

    def self.attackRange
      @attackRange
    end

    def self.movement
      @movement
    end

    def self.symb
      @symb
    end

    def self.x
      @x
    end

    def self.y
      @y
    end

    def self.isDirect
      @isDirect
    end

    def self.isDestroyed
      @isDestroyed
    end
  end

  def incHealth(num)
    @health = @health+num
    @power = 10*(@health *0.1)
  end

  def decHealth(num)
    @health = @health-num
    @power = 10*(@health *0.1)
  end

  def restockFuel()
    @ammo = 60
  end

  def decFuel(num)
    @fuel = @fuel - num
  end

  def restockAmmo()
    @ammo = 5 
	 @maxammo = 5
  end

  def decAmmo()
    @ammo = @ammo -1
  end

  def getCord()
    return [@x,@y]
  end

  def setCord(x,y)
    @x = x
    @y = y
  end

  def destroyed()
    @isDestroyed=true
  end

  def setHasMoved()
    @hasMoved = true
  end

  def setUnmoved()
    @hasMoved = false
  end

  def setCommander(player)
    @commander = player
  end

  def update  seconds_passed
    #puts("updated " + seconds_passed.to_s)
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
    @rect.topleft = [50*@y,50*@x]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end