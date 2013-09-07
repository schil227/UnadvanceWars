class PathNode
  def initialize(parentPathNode, currentNode, movementRemaining)
  @currentNode = currentNode
  @parentPathNode = parentPathNode
  @movementRemaining = movementRemaining
  
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