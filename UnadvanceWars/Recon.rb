require "rubygems"
require "rubygame"

include Rubygame

class Recon
  include Sprites::Sprite
  def initialize(x, y,playerNum)
    super()
    case (playerNum)
    when 1
      @imageName = "data/p1Recon"
    when 2
      @imageName = "data/p2Recon"
    when 3
      @imageName = "data/p3Recon"
    when 4
      @imageName = "data/p4Recon"
    end

    @image = (Surface.load(@imageName + "1.gif"))
    @rect  = Rubygame::Rect.new( 45, 50, 45, 50)
    @timeSum = 0
    @stepBool = true

    @health = 10 
	 @fuelImage = (Surface.load "data/blank.gif") 
	 @ammoImage = (Surface.load "data/blank.gif") 
	   
	 @healthImage = (Surface.load "data/blank.gif") 
 
    @power = 10*(@health * 0.1)
    @attackRange = [-1, 1]
    @movement = 8
    @symb = 'r'
    @x = x
    @y = y
    @isDirect = true;
    @isDestroyed = false;
    @hasMoved = false
    @commander = nil
    @attackTable = {}
    @secondaryAttackTable = {'i' => 0.7, 'm' => 0.65 , 'r' => 0.35, 't' => 0.06, 'M' => 0.01, 'p' => 0.45, 'a' => 0.45, 'R' => 0.55, 'A' => 0.04, 's' => 0.28, 'b'=> 0.10, 'T' => 0.35}
    @ammo = 0 
	 @maxAmmo = 0
    @fuel = 70 
	 @maxFuel = 70
    @isFlying = false
    @isSailing = false
    @cost = 4000
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
	 healthNum = @health.ceil 
	 if(healthNum > 0 && healthNum < 10) 
		 @healthImage = (Surface.load "data/" + healthNum.to_s + ".gif") 
	 else 
		 @healthImage = (Surface.load "data/blank.gif") 
	 end 
	
    @power = 10*(@health *0.1)
  end

  def decHealth(num)
    @health = @health-num 
	 healthNum = @health.ceil 
	 if(healthNum > 0 && healthNum < 10) 
		 @healthImage = (Surface.load "data/" + healthNum.to_s + ".gif") 
	 else 
		 @healthImage = (Surface.load "data/blank.gif") 
	 end 
	
    @power = 10*(@health *0.1)
  end

  def restockFuel()
    @ammo = 70
  end

  def decFuel(num)
    @fuel = @fuel - num
  end

  def needsFuel()
    return (@fuel*1.0)/(@maxFuel*1.0) < 0.2
  end

   def needsAmmo()
    return @maxAmmo != 0 &&  (@ammo*1.0)/(@maxAmmo*1.0) < 0.2 && @maxAmmo != 0
  end

   def needsSupply()
    return ((@fuel*1.0)/(@maxFuel*1.0) < 0.2) || ((@ammo*1.0)/(@maxAmmo*1.0) < 0.2)
  end

  def restockAmmo()
    @ammo = 9
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
			 @fuelImage = (Surface.load "data/blank.gif")  
			 if(self.needsAmmo()) 
				 @ammoImage = (Surface.load "data/lowAmmo.gif") 
			 end 
	   else 
			 @image = (Surface.load(@imageName + "1.gif")) 
			 @ammoImage = (Surface.load "data/blank.gif") 
			 if(self.needsFuel()) 
				 @fuelImage = (Surface.load "data/lowFuel.gif") 
			 end 
      end
      @stepBool = !@stepBool
    end
    @rect.topleft = [50*@y,50*@x]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect 
	 @healthImage.blit  on_surface, @rect 
	 @fuelImage.blit  on_surface, @rect 
	  @ammoImage.blit  on_surface, @rect 
	  
  end

end