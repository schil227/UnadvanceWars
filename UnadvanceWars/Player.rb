class Player
  def initialize(name, num)
    @name = name
    @playerNum = num
    @units = []
    @isTurn = false
    @funds = 20000
    @numOwnedCities = 0
    
    def self.funds
      @funds
    end
    
    def self.name
      @name
    end
    
    def self.playerNum
      @playerNum
    end

    def self.units
      @units
    end
    
    def self.numOwnedCities
      @numOwnedCities
    end
    
  end

  def incNumOwnedCities
    @numOwnedCities += 1
  end
  
  def decNumOwnedCities
    @numOwnedCities -= 1
  end
  
  def acquireFunds()
    @funds += (100 * @numOwnedCities)
  end
  
  def decreaseFunds(expense)
    @funds = @funds - expense
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
  
  def printUnits()
    @units.collect{|unit| unit.class}
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