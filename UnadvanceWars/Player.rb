class Player
  def initialize(name, num)
    @name = name
    @playerNum = num
    @units = []
    @isTurn = false
    
    def self.name
      @name
    end
    
    def self.playerNum
      @playerNum
    end

    def self.units
      @units
    end
  end

  def isUnit(unit)
    return (@units.include?(unit))
  end

  def addUnits(unitArray) ###CHANGE TO THIS INSTANCE INSTED OF PASSING PLAYER
    @units.concat(unitArray)
    for unit in unitArray
      unit.setCommander(self)
    end
  end

  def removeUnit(unit)
    @units.delete(unit)
  end

  def toggleIsTurn()
    !@isTurn
  end

  def hasUnusedUnits()
    for n in @units
      if(!n.hasMoved)
        return true
      end
    end
    return false
  end

end