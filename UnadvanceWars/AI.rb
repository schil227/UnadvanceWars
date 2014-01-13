class AI
  #The begining of the end.
  #oh, Fuck me this'll be a trial.
  def initialize(name, num, difficulty)
    @name = name
    @playerNum = num
    @units = []
    @isTurn = false
    @funds = 20000
    @numOwnedCities = 0
    @difficulty = difficulty
    @citySpaces =[]
    @mandatedUnits = []
    @armyIsSetUp = false
    def self.mandatedUnits
      @mandatedUnits
    end

    def self.citySpaces
      @citySpaces
    end

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

    def self.difficulty
      @difficulty
    end

    def self.armyIsSetUp
      @armyIsSetUp
    end
  end

  def appendmandatedUnits(newMandatedUnits)
    @mandatedUnits.concat(newMandatedUnits)
  end

  def removeMandatedUnit(units)
    @mandatedUnits.delete(units)
  end

  def addCitySpace(space)
    @citySpaces << space
  end

  def removeCitySpace(space)
    @citySpaces.delete(space)
  end

  def incNumOwnedCities
    @numOwnedCities += 1
  end

  def decNumOwnedCities
    @numOwnedCities -= 1
  end

  def acquireFunds()
    @funds += (1000 * @numOwnedCities)
  end

  def decreaseFunds(expense)
    @funds = @funds - expense
  end

  def isUnit(unit)
    return (@units.include?(unit))
  end

  def addUnits(unitArray)
    if !unitArray.empty?

      @units.concat(unitArray)

      for unit in unitArray
        unit.setCommander(self)
      end
      if(@armyIsSetUp == false)
        @armyIsSetUp = true
      end
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