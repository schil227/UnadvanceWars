class PathNode
  def initialize(parentPathNode, currentNode, movementRemaining, fuel)
    @currentNode = currentNode
    @parentPathNode = parentPathNode
    @movementRemaining = movementRemaining
    @fuel = fuel
    
    def self.fuel
      @fuel
    end

    def self.movementRemaining
      @movementRemaining
    end

    def self.currentNode
      @currentNode
    end

    def self.parentPathNode
      @parentPathNode
    end
  end

end