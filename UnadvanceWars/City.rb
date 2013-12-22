require "rubygems"
require "rubygame"

include Rubygame

class City

  include Sprites::Sprite
  def initialize(space, typeNumber, initialCommanderNumber)
    super()
    @occoupiedPlayer = nil
    @cityLevel = 20
    @defence = 3
    @movement = 1
    @space = space

    @x = @space.y
    @y = @space.x
    @typeNumber = typeNumber
    @initialCommanderNumber = initialCommanderNumber
    @isCapital = false
    @imageName = ""
    @imageName = setImageName(initialCommanderNumber,typeNumber)

    @image = (Surface.load @imageName)
    @rect = @image.make_rect
    @timeSum = 0
    @stepBool = true
    @landUnits= [["Infantry", 1000], ["Mech", 3000], ["Recon", 4000], ["APC", 5000], ["Tank", 6000], ["Artillery", 7000], ["AntiAir", 8000], ["Missile", 14000], ["Rocket", 15000], ["MedTank", 16000]]
    @seaUnits= [["Lander",12000],["Cruiser", 18000],["Submarine",20000],["Battleship", 28000]]
    @airUnits= [["TChopper",7000],["BChopper",9000],["Fighter", 20000],["Bomber", 22000]]
    @createableUnits

    def self.x
      @x
    end

    def self.y
      @y
    end

    def self.cityLevel
      @cityLevel
    end
    def self.createableUnits
      @createableUnits
    end

    def self.initialCommanderNumber
      @initialCommanderNumber
    end

    def self.occoupiedPlayer
      @occoupiedPlayer
    end

    def self.movement
      @movement
    end

    def self.defence
      @defence
    end

    def self.isCapital
      @isCapital
    end

    def self.typeNumber
      @typeNumber
    end

    def self.space
      @space
    end

  end

  def setImageName(playerNumber,typeNumber)
    imageName = "data/p" + playerNumber.to_s
    case typeNumber
    when 0
      imageName+= "City.gif"
    when 1
      imageName+= "Capital1.gif"
      setCapital()
    when 2
      imageName+= "Base1.gif"
      @createableUnits =@landUnits
    when 3
      imageName+= "Port1.gif"
      @createableUnits = @seaUnits
    when 4
      imageName+= "Airport1.gif"
      @createableUnits = @airUnits
    end
    return imageName
  end

  def conquer(unitHealth, unitCommander )
    playerUnderSiege = @occoupiedPlayer
    @cityLevel -= unitHealth
    if(@cityLevel < 1)

      if(playerUnderSiege != nil)
        playerUnderSiege.decNumOwnedCities()
        playerUnderSiege.removeCitySpace(@space)
      end
      @cityLevel = 20
      setOccoupiedPlayer(unitCommander)
      unitCommander.addCitySpace(@space)
      if(@isCapital)
        return true
      end
    end
    return false
  end

  def setCapital()
    @isCapital = true
    @defence = 4
  end

  def setOccoupiedPlayer(commander)
    @occoupiedPlayer = commander
    commander.incNumOwnedCities()
    @imageName = setImageName(commander.playerNum,@typeNumber)
    @image = (Surface.load(@imageName))
  end

  def update  seconds_passed
    @timeSum += seconds_passed *10
    if(@timeSum >= 5)
      @timeSum = 0
      if(@stepBool)
        if(@typeNumber == 1 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Capital1.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 2 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Base1.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 3 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Port1.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 4 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Airport1.gif"
          @image = (Surface.load(@imageName))
        end
        ##add more cases HERE
      else
        if(@typeNumber == 1 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Capital2.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 2 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Base2.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 3 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Port2.gif"
          @image = (Surface.load(@imageName))
        elsif(@typeNumber == 4 && @occoupiedPlayer != nil)
          @imageName = "data/p" + @occoupiedPlayer.playerNum.to_s + "Airport2.gif"
          @image = (Surface.load(@imageName))
        end
        ##add more cases HERE
      end
      @stepBool = !@stepBool
    end
    @rect.topleft = [50*@x,50*@y]
  end

  def draw  on_surface
    @image.blit  on_surface, @rect
  end

end