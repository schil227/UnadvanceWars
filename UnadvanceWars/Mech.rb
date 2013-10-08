require "rubygems"
require "rubygame"

include Rubygame

class Mech
  include Sprites::Sprite
  def initialize(x, y, playerNum)

    super()
    case (playerNum)
    when 1
      @imageName = "data/p1Mech"
    when 2
      @imageName = "data/p2Mech"
    when 3
      @imageName = "data/p3Mech"
    when 4
      @imageName = "data/p4Mech"
    end

    @image = (Surface.load(@imageName + "1.gif"))
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @stepBool = true

    @health = 10
    @power = 10*(@health *0.1)
    @attackRange = [-1, 1]
    @movement = 2
    @symb = 'm'
    @x = x
    @y = y
    @isDirect = true;
    @isDestroyed = false;
    @hasMoved = false
    @commander = nil
    @attackTable = {'r' => 0.85, 't' => 0.55, 'M' => 0.15, 'p' => 0.75, 'a' => 0.70, 'R' => 0.85, 'A' => 0.65, 's'=> 0.85}
    @secondaryAttackTable = {'i' => 0.65, 'm' => 0.55, 'r' => 0.18,'t' => 0.06, 'M' => 0.01, 'p' => 0.20, 'a' => 0.32, 'R' => 0.35, 'A' => 0.06, 's' => 0.35, 'b'=> 0.09 , 'T' =>0.35 }
    @ammo = 3
    @fuel = 70
    @isFlying = false
    @isSailing = false
    @cost = 3000
    @unitCommands = ['attack','wait','join','capture']
    @isCapturing = false

    def self.isCapturing
      @isCapturing
    end

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

  def startedCapturing()
    @isCapturing = true
  end

  def stoppedCapturing()
    @isCapturing = true
  end

  def restockFuel()
    @ammo = 99
  end

  def decFuel(num)
    @fuel = @fuel - num
  end

  def restockAmmo()
    @ammo = 99
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