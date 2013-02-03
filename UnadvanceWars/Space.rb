require "rubygems"
require "rubygame"

include Rubygame

class Space
  
  include Sprites::Sprite
  def initialize(width, height)
    
    super()
    @defence = nil
    @x = height
    @y = width
    @movement = nil
    @occoupiedWM = nil
    @occoupiedB = nil
    @tmpSpace = false
    @isCursor = false
    @terrain = nil
    @spaceMvmt = 0
    @tmpOccoupiedWM = nil

    @image = (Surface.load "blank.gif")
    @rect = @image.make_rect
    
    def self.tmpOccoupiedWM
      @tmpOccoupiedWM
    end
    
    def self.spaceMvmt
      @spaceMvmt  
    end
    
    def self.terrain
      @terrain
    end

    def self.isCursor
      @isCursor
    end

    def self.tmpSpace
      @tmpSpace
    end

    def self.occoupiedB
      @occoupiedB
    end

    def self.occoupiedWM
      @occoupiedWM
    end

    def self.defence
      @defence
    end

    def self.y
      @y
    end

    def self.x
      @x
    end

    def self.movement
      @movement
    end
  end
  
  def setTmpOccoupiedWM(warMachine)
    @tmpOccoupiedWM = warMachine
  end
  
  def setSpaceMvmt(num)
    @spaceMvmt = num
  end

  def resetSpaceMvmt
    @spaceMvmt = 0
  end
  
  def setOccoupiedWM(warMachine)
    @occoupiedWM = warMachine
  end

  def setOccoupiedB(building)
    @occoupiedB = building
  end

  def removeOccoupiedWM()
    @occoupiedWM = nil
  end

  def toggleTmpSpace()
    if(@tmpSpace)
      @tmpSpace = false
    else
      @tmpSpace = true
    end
  end

  def toggleIsCursor()
    if(@isCursor)
      @isCursor = false
    else
      @isCursor = true
    end
  end
  
  def setIsCursorFalse()
    @isCursor = false
  end

  def getCord()
    return [@x,@y]
  end

  def getChar()
    if(@isCursor)
      return 'X'
    end
    if(@tmpSpace)
      return 'x'
    end
    if(@occoupiedWM)
      return @occoupiedWM.symb
    end
    if(occoupiedB)
      return @occoupiedB.symb
    end
    return @defence.to_s
  end

  def setTerrainValues(terrain)
    @defence = terrain.defence
    @movement = terrain.movement
    @terrain = terrain
  end

  def update  seconds_passed
    if(@isCursor || @tmpspace)
      @image = (Surface.load "cursor.gif")
    else
      @image = (Surface.load "blank.gif")
    end
    @rect.topleft = [50*@y,50*@x]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end