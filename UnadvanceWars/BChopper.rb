require "rubygems"
require "rubygame"

include Rubygame

class BChopper
  include Sprites::Sprite
  def initialize(x, y,playerNum)
    super()
    case (playerNum)
    when 1
      @imageName = "data/p1BChopper"
    when 2
      @imageName = "data/p2BChopper"
    when 3
      @imageName = "data/p3BChopper"
    when 4
      @imageName = "data/p4BChopper"
    end

    @image = (Surface.load(@imageName + "1.gif"))
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @stepBool = true

    @health = 10
    @power = 10*(@health * 0.1)
    @attackRange = [-1, 1]
    @movement = 6
    @isFlying = true
    @symb = 'b'
    @x = x
    @y = y
    @isDirect = true;
    @isDestroyed = false;
    @hasMoved = false
    @commander = nil #FOR ATTACK TABLE, SHOULD GIVE CHOPPER AMMO BACK IF ATTACKING CHOPPER OR INF (MG)
    @attackTable = {'r' => 0.55, 't' => 0.55, 'M' => 0.25, 'p' => 0.65, 'a' => 0.65, 'R' => 0.65, 'A' => 0.25, 's' => 0.65, 'L' => 0.25, 'C' => 0.55, 'S' => 0.25, 'B' => 0.25}
    @secondaryAttackTable = {'i' => 0.75, 'm' => 0.75, 'r' => 0.30, 't' => 0.06, 'M' => 0.01, 'p' => 0.20, 'a' => 0.25, 'R' => 0.35, 'A' => 0.06, 's' => 0.35, 'b'=> 0.65, 'T' => 0.95 }
    @ammo = 6
    @fuel = 99
    @isSailing = false
    @cost = 9000
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

    def decTurnFuel()
      @fuel = @fuel - 2
    end

    def self.ammo
      @ammo
    end

    def self.attackTable
      @attackTable
    end

    def self.secondaryAttackTable
      @secondaryAttackTable
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
    @ammo = 99
  end

  def decFuel(num)
    @fuel = @fuel - num
  end

  def restockAmmo()
    @ammo = 6
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