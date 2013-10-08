require "./Space.rb"
require "rubygems"
require "rubygame"

include Rubygame

class Field
  def initialize(x,y)
    @x = x
    @y = y
    @sfield = Array.new
    def self.sfield
      @sfield
    end

    def self.y
      @y
    end

    def self.x
      @x
    end
  end

  def setupField(map)
    for i in 0..(@x-1) do
      for j in 0..(@y-1)
        @sfield.concat([Space.new(i,j)])

      end
    end
    return setupTerrain(map)
  end

  def setupTerrain(map)
    file = File.open(map,'r')
    terrainArray=[]
    cityArr=[]
    for line in file
      for char in line.each_char
        if char != "\n"
          terrainArray << char
        end
      end
    end
    x=0
    for space in @sfield #perhapse take in a list of values which corospond to a pre-made field
      case terrainArray.at(x)
      when ("0")
        space.setTerrainValues(Road.new(space))
      when ("1")
        space.setTerrainValues(Grass.new(space))
      when ("2")
        space.setTerrainValues(Forest.new(space))
      when ("C")
        space.setTerrainValues(City.new(space, terrainArray.at(x+1).to_i,terrainArray.at(x+2).to_i))
        cityArr.push(space.terrain)
        x+=2
        p("still hope this doesnt print every time")
      when ("4")
        space.setTerrainValues(Mountain.new(space))
      when ("5")
        space.setTerrainValues(Sea.new(space))
      when ("6")
        space.setTerrainValues(Shoal.new(space))
      end
      x+=1
    end
    return cityArr
  end

  def addWM(warMachine)
    for space in @sfield
      if space.getCord == warMachine.getCord
        if(space.occoupiedWM != nil)
          p("space occoupied, setting tmp")
          space.setTmpOccoupiedWM(warMachine)
        else
          p("space unoccoupied")
          space.setOccoupiedWM(warMachine)
        end
      end
    end
  end

  def removeWM(warMachine)
    for space in @sfield
      if space.getCord == warMachine.getCord
        if(space.tmpOccoupiedWM())
          space.setTmpOccoupiedWM(nil)
        else
          space.removeOccoupiedWM()
        end
      end
    end
  end

  def printField()
    strArry = ""
    for i in 0..(@y-1)
      for x in @sfield[((i*@x))..((i+1)*@x -1)] #if x == 10, 0 - 9. 10- 19, etc.
        strArry.concat(x.getChar())
      end
      puts strArry
      strArry.clear()
    end
    puts()
  end

  def getSpace(cord)
    for space in @sfield
      if space.getCord == cord
        return space
      end
    end
    p("SPACE NOT FOUND. Check if argument is in proper form")
    return nil
  end

  def listOfCords()
    arr = []
    for space in @sfield
      arr.concat([[space.x, space.y]])
    end
    return arr
  end

end
