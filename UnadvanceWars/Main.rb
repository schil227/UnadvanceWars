#!/usr/bin/ruby
Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" && file != "./textEx.rb")
    require file
  end}

require 'rubygems'
require 'rubygame'

include Rubygame

def setup(useUnits)
  map = "data/map1.txt"
  file = File.open(map,'r')
  @mapx = file.read.count("\n")
  file.rewind
  @mapy = file.readline().size - 1
  @field = Field.new(@mapx, @mapy) #x & y are flipped D:
  @cityArr = @field.setupField(map)

  @consoleXCord = @mapx * 50 + 5
  @screen = Screen.open [@mapx * 50 + 175, @mapy *50 + 25]
  @clock = Clock.new
  @clock.target_framerate = 60
  @clock.enable_tick_events
  @background = Surface.load "data/background.png"
  @background.blit @screen, [ 0, 0]

  Sound.autoload_dirs = [ File.dirname(__FILE__) ]
  @explosionSound = Sound['data/explosion.wav']
  @explosionSound.volume = 0.25

  @superThemeMusic =  Music.load('data/marchOfTheSOD.mp3')
  @superThemeMusic.volume = 0.25
  #@superThemeMusic.play(:repeats => -1)

  #  @superThemeMusic.play()
  #  @musicThread = Thread.new{
  #    while true
  #      if(!@superThemeMusic.playing?)
  #        @superThemeMusic.play
  #      end
  #      sleep(1)
  #    end
  #  }
  #  @musicThread.priority = -1
  #
  #  @musicThread.join()
  @sprites = Sprites::Group.new
  Sprites::UpdateGroup.extend_object @sprites

  for space in @field.sfield
    @sprites.concat([space.terrain])
  end
  #####################smooth, colorArr, baseSize,xCord,yCord)
  @console = Console.new(@consoleXCord,  @mapy *50)
  @sprites << @console

  @infoBar = InfoBar.new(@mapy *50)
  @sprites << @infoBar

  @event_queue = EventQueue.new
  @event_queue.enable_new_style_events

  player1 = Player.new("RED",1)
  player2 = AI.new("BLUE",2, 1)

  @listOfP = [player1,player2]

  if(useUnits)
    p1Units = [
      mTank = MedTank.new(7,8,1),
      art = Artillery.new(2,3,1),
      tank2 = Tank.new(0,4,1),
      inf = Infantry.new(6,7,1),
      chop = BChopper.new(8,15,1),
      #bat = Battleship.new(3,11,1),
      bomb = Bomber.new(4,5,1),
      # crsr = Cruiser.new(3,10,1),
      recon1 = Recon.new(2,8,1),
      mech1 = Mech.new(2,9,1),
      apc = APC.new(6,8,1),
      lan = Lander.new(6,11,1),
    ]

    p2Units = [
      #      mTank2 = MedTank.new(6,1,2),
      #      tank = Tank.new(1,3,2),
      #      art2 = Artillery.new(0,1,2),
      #      art3 = Artillery.new(1,1,2),
      #      rocket = Rocket.new(0,2,2),
      #      aa = AntiAir.new(1,6,2),
      #fgtr = Fighter.new(2,14,2),
      #      sub = Submarine.new(2,11,2),
      #      recon = Recon.new(3,9,2),
      #      mech = Mech.new(1,9,2),
      mech2 = Mech.new(8,18,2),
      apc = APC.new(7,18,2),
    ]
    player1.addUnits(p1Units)
    player2.addUnits(p2Units)
  end

  for city in @cityArr
    if(city.initialCommanderNumber != 0) #if 0 then unconqured city
      player = @listOfP.at(city.initialCommanderNumber-1)
      city.setOccoupiedPlayer(player) #number is adjusted for the list  location
      player.citySpaces << city.space
    end
  end

  for u in player1.units
    @field.addWM(u)
    @sprites << u
  end

  for u in player2.units
    @field.addWM(u)
    @sprites << u
  end

end

###Combat###
def attack(attacker, attacked,currentPlayer)
  p("before attack:")
  p("Attaking " + attacker.class.to_s + " health: " + (attacker.health).to_s)
  p("Defending " + attacked.class.to_s + " health: " + (attacked.health).to_s)
  attacked.decHealth(calcDamage(attacker,attacked)) #would add land def here
  attacker.decAmmo
  if(attacked.health > 0 && attacker.isDirect && attacked.isDirect) #counter attack, D v D only
    attacker.decHealth(calcDamage(attacked,attacker))
    attacked.decAmmo
  elsif(attacked.health < 1)
    p("Defending " + attacked.class.to_s + " was destroyed!")
    destroy(attacked, attacked.commander)
  end
  if(attacker.health < 1) #destroyed in counter attack
    p("Attacking " + attacker.class.to_s + " was destroyed!")
    destroy(attacker, attacker.commander)
  end
  p("After attack:")
  p("Attaking " + attacker.class.to_s + " health: " + (attacker.health).to_s)
  p("Defending " + attacked.class.to_s + " health: " + (attacked.health).to_s)

end

def destroy(warMachine, currentPlayer)
  @sprites.delete(warMachine)
  if(warMachine.unitCommands.include?("deploy") && warMachine.hasDeployableUnits)
    for unit in warMachine.convoyedUnits
      destoryOffScreenUnit(unit,currentPlayer)
    end
  end
  warMachine.destroyed()
  explosion(warMachine.y, warMachine.x)
  currentPlayer.removeUnit(warMachine)
  @field.removeWM(warMachine)
end

def destoryOffScreenUnit(warMachine, currentPlayer)
  if(warMachine.unitCommands.include?("deploy") && warMachine.hasDeployableUnits)
    for unit in warMachine.convoyedUnits
      destoryOffScreenUnit(unit,currentPlayer)
    end
  end
  warMachine.destroyed()
  currentPlayer.removeUnit(warMachine)
end

def destroyAllUnits(commander)
  unitLength = commander.units.length
  for i in 0 .. unitLength-1
    destroy(commander.units.at(0),commander)
  end
end

def calcDamage(attacker, attacked)
  attackPower = 0
  if(attacker.ammo > 0 && attacker.attackTable[attacked.symb] != nil)
    attackPower = attacker.attackTable[attacked.symb] * (attacker.power)
  elsif( defined?(attacker.secondaryAttackTable))
    if(attacker.secondaryAttackTable[attacked.symb] != nil)
      attackPower = attacker.secondaryAttackTable[attacked.symb] * (attacker.power)
    end
  else
    p("couldnt attack!")
    return 0
  end
  return (attackPower - @field.getSpace(attacked.getCord).defence*((attackPower*(0.1)) - (attackPower * 0.01 * (10 - attacked.health))))
end

def explosion(x,y)
  explosion = Explosion.new(x, y)
  @sprites << explosion
  exploding = true
  timeSum = 0
  @explosionSound.play
  while(exploding)
    seconds_passed = @clock.tick().seconds
    timeSum+= seconds_passed
    update(seconds_passed)
    if(timeSum > 0.8)
      exploding = false
    end
  end
  @sprites.delete(explosion)
end

def simulateAttack(attacker, attacked)
  score = 0
  score = score + calcDamage(attacker,attacked)
  attacked.decHealth(calcDamage(attacker,attacked))
  p("The score is:" + score.round.to_s)
  if(attacked.health > 0 && attacker.isDirect && attacked.isDirect)
    score = score - calcDamage(attacked,attacker)
  end
  return score
end

def genRange(attackRange, spot)
  x = spot.at(0)
  y = spot.at(1)
  min = attackRange[0]
  max = attackRange[1]
  listOfSpots = []
  for i in 0..max #test
    if(min - i > 0)
      for j in (min - i)..(max - i)
        listOfSpots.concat([[i+x,j+y],[-i+x,j+y],[i+x,-j+y],[-i+x,-j+y]])
      end
    else
      for j in 0..(max-i)
        listOfSpots.concat([[i+x,j+y],[-i+x,j+y],[i+x,-j+y],[-i+x,-j+y]])
      end
    end
  end
  listOfCords = @field.listOfCords()

  listOfSpots = (listOfSpots.uniq()).delete_if{|x| x == spot || !listOfCords.include?(x)}
  listOfSpaces = []
  for cord in listOfSpots
    listOfSpaces << (@field.getSpace(cord))
  end
  return listOfSpaces
end

def isSusceptibleToAttack(attacker, defender)
  #SubmarineCase
  #ruby is lazy, therefore the defender.submerged call will not be evaluated until it is confirmed that the class is Submarine
  if (defender.class == Submarine && attacker.class != Cruiser && attacker.class != Submarine && defender.submerged)
    return false
  end
  return true
end

def attackableWarMachines(arr,currentPlayer, warMachine) #array of Cords
  p(warMachine.class)
  wMarr=[]
  currentSpace=nil
  for currentSpace in arr
    if (currentSpace.occoupiedWM)
      if(!currentPlayer.isUnit(currentSpace.occoupiedWM))
        if((warMachine.attackTable[currentSpace.occoupiedWM.symb] != nil) && isSusceptibleToAttack(warMachine, currentSpace.occoupiedWM))
          wMarr.concat([currentSpace.occoupiedWM])
        elsif(defined?(warMachine.secondaryAttackTable))
          if((warMachine.secondaryAttackTable[currentSpace.occoupiedWM.symb] != nil) && isSusceptibleToAttack(warMachine, currentSpace.occoupiedWM))
            wMarr.concat([currentSpace.occoupiedWM])
          end
        end
      end
    end
  end
  return wMarr
end

def selectTarget(warMachine, attackableWMs) #cycles 'left' and 'right' through the list of attackable WMs
  @infoBar.modifyText("Select target: cycle (a) left and (d) right, (f) to select")
  x = 0
  currentWM = attackableWMs.at(x)
  currentWMSpace = @field.getSpace([currentWM.x, currentWM.y])

  currentWMSpace.toggleIsCursor()
  @sprites << currentWMSpace
  unselected = true

  while unselected
    updateConsoleLockUnit(currentWMSpace.terrain,currentWM,calcDamage(warMachine,currentWM))
    # p("warM: " + warMachine.class.to_s + " currentWM: " + currentWM.class.to_s)
    # p("warM ammo : " + warMachine.ammo.to_s)
    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      when Events::QuitRequested
        throw :rubygame_quit
      when Events::KeyPressed
        if(event.key == :a)
          if(x == 0)
            x = attackableWMs.length()-1
          else
            x -= 1
          end
          currentWM = attackableWMs.at(x)
          currentWMSpace.toggleIsCursor()
          @sprites.delete(currentWMSpace)
          currentWMSpace = @field.getSpace([currentWM.x, currentWM.y])
          currentWMSpace.toggleIsCursor()
          @sprites << currentWMSpace
        elsif(event.key == :d)
          if(x == attackableWMs.length()-1)
            x = 0
          else
            x += 1
          end
          currentWM = attackableWMs.at(x)
          currentWMSpace.toggleIsCursor()
          @sprites.delete(currentWMSpace)
          currentWMSpace = @field.getSpace([currentWM.x, currentWM.y])
          currentWMSpace.toggleIsCursor()
          @sprites << currentWMSpace

        elsif(event.key == :f)
          currentWMSpace.toggleIsCursor()
          @sprites.delete(currentWMSpace)
          unselected = false

        else
          #@infoBar.modifyText("Select The machine you want to attack: cycle (a) left and (b) right, (f) to select")
        end
      end
    end
  end
  return currentWM
end

def genAttackRange(warMachine)
  attackRange = genMoveRange2(warMachine)
  newSpots = []

  for spot in attackRange
    newSpots.concat(getNeighboringSpaces(spot)) #my lazyness knows no bounds
  end

  p("attackrange before add:" + attackRange.length.to_s)
  for spot in newSpots
    if(spot != nil && !attackRange.include?(spot))
      attackRange << spot
    end
  end
  attackRange = attackRange.uniq()
  p("attackrange after:" + attackRange.length.to_s)

  return attackRange
end

###Movement###

def genMoveRange2(warMachine)
  spaceArr = []
  currentSpace = @field.getSpace(warMachine.getCord)
  spaceArr.concat(genSpaceMovement(currentSpace, warMachine.movement, spaceArr, warMachine))

  for space in spaceArr
    space.resetSpaceMvmt
  end
  return spaceArr.uniq()
end

def genMoveRange(warMachine,movement, currentSpace)
  spaceArr = []
  spaceArr.concat(genSpaceMovement(currentSpace, movement, spaceArr, warMachine))

  for space in spaceArr
    space.resetSpaceMvmt
  end
  return spaceArr.uniq()
end

def getNeighboringSpaces(space)

  nSpace = @field.getSpace([space.x-1, space.y])
  sSpace = @field.getSpace([space.x+1, space.y])
  eSpace = @field.getSpace([space.x, space.y+1])
  wSpace = @field.getSpace([space.x, space.y-1])

  return [nSpace, sSpace, eSpace, wSpace]
end

def genSpaceMovement(space, mvmt, spaceArr, warMachine)
  spaceArr.concat([space])

  nSpace = @field.getSpace([space.x-1, space.y])
  sSpace = @field.getSpace([space.x+1, space.y])
  eSpace = @field.getSpace([space.x, space.y+1])
  wSpace = @field.getSpace([space.x, space.y-1])

  #(space.occoupiedWM && space.occoupiedWM != warMachine)
  #&& !space.occoupiedWM

  tmpSpaceArr = [nSpace, sSpace, eSpace, wSpace]
  for space in tmpSpaceArr
    if(space != nil && mvmt > 0)
      if((space.movement <= mvmt ||(warMachine.isFlying && 1 <= mvmt)) && mvmt > space.spaceMvmt && \
      !( (space.occoupiedWM && (space.occoupiedWM.commander != warMachine.commander)) \
      || (space.terrain.class == Mountain && (warMachine.class != (Infantry || Mech) && !warMachine.isFlying)) \
      || (space.terrain.class == Sea && (!warMachine.isFlying && !warMachine.isSailing)) \
      || (space.terrain.class != Sea && space.terrain.class != Shoal && warMachine.isSailing)))
        space.setSpaceMvmt(mvmt)
        if(warMachine.isFlying)
          spaceArr.concat(genSpaceMovement(space, mvmt - 1, spaceArr, warMachine))
        else
          spaceArr.concat(genSpaceMovement(space, mvmt - space.movement, spaceArr, warMachine))
        end
      end
    end
  end
  return spaceArr.uniq()
end

def optimizeMovePath(startSpace, moveRange, endSpaces, unit)
  #generate list of all spaces which include end space, parent/child node structure!
  #select shortest from the path which gets there first
  startNode = PathNode.new(nil, startSpace, moveRange)
  allNodesPassed= [startNode.currentNode]
  currentNodes = [startNode]
  for endSpace in endSpaces
    if(startNode.currentNode == endSpace)
      return startNode
    end
  end
  return optimizeMovePathRecursion(currentNodes, allNodesPassed, endSpaces, unit)
end

def optimizeMovePathRecursion(currentNodes, allSpacesPassed, endSpaces, unit)
  spaceFound = false
  solution = nil
  while !spaceFound
    pathSolutions = []
    newNodes = []
    for parentNode in currentNodes
      spaces = getApplicableNeighboringSpaces(parentNode, parentNode.movementRemaining , unit)
      p("found " + spaces.size.to_s + " space(s)")
      for space in spaces
        if(!allSpacesPassed.include?(space.currentNode))
          p("space not in all spaces yet!")
          allSpacesPassed.push(space.currentNode)
          newNodes.push(space)
          for endSpace in endSpaces
            if space.currentNode == endSpace
              pathSolutions.push(space)
            end
          end
        end
      end
    end
    # p("found all currentNodes. size: " + currentNodes.size.to_s)
    if(!pathSolutions.empty?)
      p("solutions is not empty")
      solution = pathSolutions.at(0)
      for path in pathSolutions
        if path.movementRemaining > solution.movementRemaining
          solution = path
        end
      end
      spaceFound = true
      p("found a solution path!")
    end
    if(currentNodes.empty?)
      solution = nil
      spaceFound = true
      p("Could not find a path!!!")
    end
    newNodes = newNodes.uniq {|n| n.currentNode} #should not be necessairy
    currentNodes = newNodes
  end

  return solution
  #  return optimizeMovePathRecursion(newNodes, allSpacesPassed, endSpaces, unit)
end

def getApplicableNeighboringSpaces(parentPathNode, mvmt, warMachine)
  parentSpace = parentPathNode.currentNode
  nSpace = @field.getSpace([parentSpace.x-1, parentSpace.y])
  sSpace = @field.getSpace([parentSpace.x+1, parentSpace.y])
  eSpace = @field.getSpace([parentSpace.x, parentSpace.y+1])
  wSpace = @field.getSpace([parentSpace.x, parentSpace.y-1])

  #(space.occoupiedWM && space.occoupiedWM != warMachine)
  #&& !space.occoupiedWM

  tmpSpaceArr = [nSpace, sSpace, eSpace, wSpace]
  p("parent space is at " + parentSpace.getCord.to_s + "with terrain type " + parentSpace.terrain.class.to_s)
  p("found " + tmpSpaceArr.size.to_s + " neighbor spaces")
  applicableSpaceArr = []
  for space in tmpSpaceArr
    p("trying a new space")
    if(space != nil && mvmt > 0)
      if((space.movement <= mvmt ||(warMachine.isFlying && 1 <= mvmt)) && mvmt > space.spaceMvmt && \
      !( (space.occoupiedWM && (space.occoupiedWM.commander != warMachine.commander)) \
      || (space.terrain.class == Mountain && (warMachine.class != (Infantry || Mech) && !warMachine.isFlying)) \
      || (space.terrain.class == Sea && (!warMachine.isFlying && !warMachine.isSailing)) \
      || (space.terrain.class != Sea && space.terrain.class != Shoal && warMachine.isSailing)))
        p("found a space!")
        # space.setSpaceMvmt(mvmt)
        if(warMachine.isFlying)
          p("Adding a tmpNode, mvmt:" + (mvmt - 1).to_s + ", unit:" + warMachine.class.to_s)
          tmpPathNode = PathNode.new(parentPathNode,space,mvmt - 1)
          applicableSpaceArr.push(tmpPathNode)
        else
          p("Adding a tmpNode, mvmt:" + (mvmt - space.movement).to_s + ", unit:" + warMachine.class.to_s)
          tmpPathNode = PathNode.new(parentPathNode,space,mvmt - space.movement)
          applicableSpaceArr.push(tmpPathNode)
        end

      end
    end
  end
  p("returning spaces")
  return applicableSpaceArr
end

def genPathFromNodes(pathNode, spaceArr) ## done creating opt. path and gen path, now to implement and test!
  if(pathNode  == nil) #when no spot is found; empty path set
    return spaceArr
  end
  curNode = pathNode
  spaceArr.push(curNode.currentNode)
  while(curNode.parentPathNode != nil)
    curNode = curNode.parentPathNode
    spaceArr.push(curNode.currentNode)
  end
  #spaceArr.shift
  return spaceArr
end

def calcClosestSpace(spaceArr, endSpace)
  tmpDistanceArr = []
  for space in spaceArr
    distance = Math.sqrt(((endSpace.y - space.y).abs)^2 + ((endSpace.x - space.x).abs)^2)
    tmpDistanceArr.push([space, distance])
  end
  return tmpDistanceArr.sort{|x,y| x.at(1) <=> y.at(1)}
end

def move(warMachine, spaces) #animation, setting/unsetting spaces
  timeSum = 0
  moving = true
  spaceArr = spaces.reverse
  while moving
    seconds_passed = @clock.tick().seconds

    timeSum += seconds_passed*10
    if(timeSum > 3 && warMachine.fuel > 0)
      ####Fuel is currently broken, as the path is not built (and it decrements based on distance)
      warMachine.decFuel(1)
      timeSum = 0
      x = spaceArr.pop
      @field.removeWM(warMachine)
      warMachine.setCord(x.x, x.y)
      ##if wm exists on space, set wM as tmp
      @field.addWM(warMachine)
      #@field.printField()
    end
    if(warMachine.fuel < 1)
      spaceArr.clear
    end
    if(spaceArr.empty?)
      moving = false
    end
    update(seconds_passed)
  end

end

def calcMovementReturn(spaceArr, space, warMachine)
  sum = 0
  i = spaceArr.size()-1
  spaceArr.reverse()
  until spaceArr.at(i) == space
    if(!warMachine.isFlying)
      sum += spaceArr.at(i).movement
    else
      sum += 1
    end
    i-=1
  end
  spaceArr.reverse()
  sum
end

def cutMovePath(spaceArr, space)
  i = spaceArr.size()-1
  p("before" + printSpaceArr(spaceArr))
  until spaceArr.at(i) == space
    p(spaceArr.at(i).getCord.to_s + " vs " + space.getCord.to_s)
    spaceArr.delete_at(i)
    i-=1
  end
  p("after" + printSpaceArr(spaceArr))
  return spaceArr
end

def printSpaceArr(spaceArr)
  cordString = ""
  for space in spaceArr
    cordString += ", " + space.getCord.to_s
  end
  return cordString
end

def movePath(warMachine)
  spaceArr = []
  mvmt = warMachine.movement
  currentSpace = @field.getSpace(warMachine.getCord)
  originalSpace = currentSpace
  currentSpace.toggleIsCursor()
  @sprites << currentSpace
  tmpSpace = nil
  spotSelected = false
  x = 0
  p("before gen move range")
  tmpArr = genMoveRange2(warMachine)
  for space in tmpArr
    space.toggleIsCursor()
    @sprites << space
  end

  p("after gen move range")

  @infoBar.modifyText("Move the War Machine using w,s,a,d and (f) to select")
  tmpField([currentSpace.getCord()])
  while !spotSelected
    updateConsoleLockUnit(currentSpace.terrain,nil,nil)
    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      #ADD QUIT EVENT
      when Events::QuitRequested
        throw :rubygame_quit
      when Events::KeyPressed

        if(event.key == :s)#258
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x+1, currentSpace.y])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            #@sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            # @sprites << currentSpace
          end
        elsif(event.key == :w)#259
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x-1, currentSpace.y])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            #@sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            # @sprites << currentSpace
          end
        elsif(event.key == :a)#260
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y-1])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            #@sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            # @sprites << currentSpace
          end
        elsif(event.key == :d)#261
=begin
          ##This is the code that used to be run for each key pressed. Thankfully
          #its been refactored a ton and now relies mostly on the recursive
          #method genMoveRange. This code will be left inplace as a record to
          #what it was like. In other words, R.I.P.
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y+1]) ##Right
          if (tmpSpace == nil || (tmpSpace.occoupiedWM && tmpSpace.occoupiedWM != warMachine) || (tmpSpace.terrain.class == Mountain && (warMachine.class != Infantry && !warMachine.isFlying)) || (tmpSpace.terrain.class == Sea && (!warMachine.isFlying && !warMachine.isSailing)) || (tmpSpace.terrain.class != Sea && warMachine.isSailing))
            p("DNE")
          elsif(spaceArr.include?(tmpSpace)) #space already included, destroy path and decrement x
            p("spaceArr = " + printSpaceArr(spaceArr))
            x-= calcMovementReturn(spaceArr, tmpSpace, warMachine)
            spaceArr = cutMovePath(spaceArr, tmpSpace)
            p("spaceArr = " + printSpaceArr(spaceArr))
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            p(currentSpace.getCord)
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
          elsif(tmpSpace.occoupiedWM == warMachine)
            p("Same space as original")
            x=0
            spaceArr.clear
            warMachine.setUnmoved
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            p(currentSpace.getCord)
            currentSpace.toggleIsCursor()
            @sprites << currentSpace

          elsif((x + (tmpSpace.movement) <= mvmt || (warMachine.isFlying && x+1 <= mvmt) )&& !tmpSpace.occoupiedWM ) #if remaining movement minus new space is under max movement
            p("general movement")
            if(warMachine.isFlying)
              p("Is flying, adding 1")
              x+=1
            else
              x+=tmpSpace.movement
            end
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            p(currentSpace.getCord)
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
            spaceArr.concat([currentSpace])
          end

=end
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y+1])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            #@sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            # @sprites << currentSpace
          end

        elsif(event.key == :f)
          spotSelected = true
          spaceArr.concat([currentSpace])
        else
          #@infoBar.modifyText("Move the War Machine using w,s,a,d and (f) to select")
        end
      end
    end

  end

  currentSpace.toggleIsCursor()
  @sprites.delete(currentSpace)

  for space in tmpArr
    space.setIsCursorFalse()
    @sprites.delete(space)
  end

  theMovementPath = genPathFromNodes(optimizeMovePath(originalSpace,warMachine.movement,[currentSpace],warMachine), [])
  p("here's the movement pathXXXXXXXXXXXXXXXXXXXXXX: ")
  for space in theMovementPath
    print(space.getCord().to_s + ",")
  end
  p("XXXXXXXXXXXXXXXXXXXXX")
  #move(warMachine,theMovementPath.reverse)
  return theMovementPath.reverse
end

################# A.I. ###############

def selectBest(attacker, attackableUnits)
  scores = []
  p("selecting the best target:")
  for target in attackableUnits
    attackerClone = attacker.clone
    targetClone = target.clone
    score = simulateAttack(attackerClone, targetClone).round
    p("the score is: " + score.to_s + " for unit " + target.class.to_s)
    scores << KeyValuePair.new(target,score)
  end
  p("looked at all the targets")
  sortedScores = scores.sort!{|a,b| b.value <=> a.value}
  return sortedScores.at(Random.rand(2) % attackableUnits.length).key #produces random unit choice
end

def findBestAttackPoint(unit, target, movementArr)
  p("finding best spots")
  neighboringSpaces = getNeighboringSpaces(@field.getSpace(target.getCord))
  p("got neighboring spaces")
  attackPoints = neighboringSpaces & movementArr #intersection
  p("found intersection")
  sortedAttackPoints = attackPoints.sort!{|a,b| a.defence <=> b.defence }
  p("neighboringSpaces:" + neighboringSpaces.length.to_s + " moveArr:" + movementArr.length.to_s + " intersection:" + attackPoints.length.to_s)
  return sortedAttackPoints.at(Random.rand(2) % sortedAttackPoints.length)
end

def attackUnit(unit, currentPlayer)
  if(!unit.isDirect)
    attackableUnitSpaces = attackableWarMachines(genRange(unit.attackRange,unit.getCord),currentPlayer, unit)
    if(!attackableUnitSpaces.empty?)
      attackableUnits = []
      for warMachine in attackableUnitSpaces
        attackableUnits << warMachine
      end
      p("getting target")
      target = selectBest(unit, attackableUnits)
      attack(unit, target, currentPlayer)
    end

  else #genAttackRange
    p("unit is direct")
    attackableUnitSpaces = attackableWarMachines(genAttackRange(unit),currentPlayer, unit)

    if(!attackableUnitSpaces.empty?)
      attackableUnits = []
      for warMachine in attackableUnitSpaces
        attackableUnits << warMachine
      end
      p("getting target")
      target = selectBest(unit, attackableUnits)
      p("getting target space")
      targetSpace = findBestAttackPoint(unit, target,genMoveRange(unit))
      p("going to move")
      move(unit, genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord),unit.movement,[targetSpace],unit),[]).reverse)
      attack(unit, target, currentPlayer)
    end
  end
end

def getAllDangerZones(currentPlayer)
  spaceArr = []
  for player in @listOfP
    if player != currentPlayer
      for unit in player.units
        spaceArr = spaceArr + genAttackRange(unit)
      end
    end
  end
  return spaceArr
end

def retreat(unit, citySpaces)
  p("retreating!")
  pathToCity = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord), 500, citySpaces, unit),[]).reverse
  if(pathToCity.size > 0)

    p("found the city!")
    unitPath = []
    mvmt = unit.movement
    i = 0
    p("The class of the pathToCity:" + pathToCity.class.to_s)
    p("The class of the first element:" + pathToCity.at(0).class.to_s)
    p("the array size: "+ pathToCity.size.to_s)
    p("spaces in unitPath:")
    pathToCity.shift #pops off the first element (home square)
    for space in unitPath
      print(space.class.to_s + ", ")
    end

    unitPath = getAsFarAsPossible(unit,pathToCity,unit.movement)
    p("unit path length:" + unitPath.size.to_s)
    targetSpace = refactorBestPath(unit,unitPath,1)
    if(targetSpace != nil)
      p("the targetSpace cords are:" +targetSpace.getCord().to_s + " with type " + targetSpace.terrain.class.to_s)
      unitPath = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord), unit.movement, [targetSpace], unit),[]).reverse
      p("unit path length ref:" + unitPath.size.to_s)
      p("path to city size:" + pathToCity.size.to_s + ", unitPath size:" + unitPath.size.to_s)
    else
      p("targetspace was null")
    end
    #    if(unitPath.size > 0)
    #      unitPath = dropSpacesWithUnits(unitPath)
    #    end
    if(unitPath.size > 0)
      move(unit, unitPath)
    end
    p("done retreating")
  else #Can't find a

  end
end

def dropSpacesWithUnitsWhenJoining(unitPath) #necessairy?
  #would you seek out units to join together, or would they be in range?
end

def dropSpacesWithUnits(unitPath)
  p("before unitPath size:"+ unitPath.size.to_s)
  i = unitPath.size-1
  while(unitPath.size>0  && unitPath.at(i).occoupiedWM != nil) #if size is one, then were're on the spot of our current wm
    p("found a unit and size>0. i:" + i.to_s)
    unitPath = unitPath[0...-1] #drops last unit
    i = unitPath.size-1
  end
  p("after unitPath size:"+ unitPath.size.to_s)
  return unitPath
end

def spaceIsDangerous(space)
  return @dangerZones.include?(space)
end

def openEnoughSpace(space, numOpenEnough)
  if(numOpenEnough == 1)
    return true #the space itself is assuemd opened from refactorBestPath method
  elsif(numOpenEnough == 2) #
    spaces = getNeighboringSpaces(space)
    for space in spaces
      if space.occoupiedWM == nil
        return true
      end
    end
  end
  return false
end

def refactorBestPath(unit, unitPath, requiredOpenness) #returns an optimal space to go to from a path
  t1 = Time.new()
  p("time1:" + t1.to_s)

  currentSpace = unitPath.last
  size = unitPath.size
  goodSpace = nil
  possibleSolutions =[]
  allSpots = []

  p("the starting space is:" + currentSpace.getCord.to_s + ", type:" + currentSpace.terrain.class.to_s)
  #initial space check
  if(currentSpace.occoupiedWM == nil && openEnoughSpace(currentSpace,requiredOpenness)) #currentspace
    if((!spaceIsDangerous(currentSpace))  && goodSpace == nil ) # || (Random.rand(2) == 1)) choose a dangerous space sometimes
      p("THE PERFECT SPACE! REJOYCE! dangerous?: ")
      goodSpace = currentSpace
    else
      p("A DANGEROUS SPACE! BEWARE!")
      possibleSolutions << currentSpace
    end
  else
    p("movin on to other spaces")
  end

  allSpots << currentSpace
  mvmt = currentSpace.movement
  unitPath = unitPath[0...-1]
  currentSpace = unitPath.last

  while(unitPath.size>0  && goodSpace == nil && mvmt > 0)
    p("mvmt: " + mvmt.to_s + ", starting space is:" + currentSpace.getCord.to_s + ", type:" + currentSpace.terrain.class.to_s)
    moveRange = genMoveRange(unit,mvmt,currentSpace)
    for space in moveRange
      p("checkin space:" + space.getCord.to_s + ", type:" + space.terrain.class.to_s)
      if(!allSpots.include?(space) && space.occoupiedWM == nil && openEnoughSpace(space,requiredOpenness)) #currentspace
        if((!spaceIsDangerous(space) ) && goodSpace == nil ) #choose a dangerous space sometimes
          p("THE PERFECT SPACE! REJOYCE!") #|| (Random.rand(2) == 1)
          goodSpace = space
        elsif(!spaceIsDangerous(space))
          p("space not dangerous, but goodspace claimed")
          possibleSolutions << space
        else
          p("A DANGEROUS SPACE! BEWARE!")
          possibleSolutions << space
        end
      else
        "Not a good spot."
      end
      allSpots << space
    end
    if((unitPath.size*1.0) / (size*1.0) < 0.5)
      mvmt = mvmt + currentSpace.movement
    else
      mvmt = mvmt - currentSpace.movement
    end

    currentSpace = unitPath.last
    unitPath = unitPath[0...-1]

  end

  t2 = Time.new()
  p("time2:" + t2.to_s)
  if(goodSpace != nil)
    p("returning the good space")
    return goodSpace
  elsif(!possibleSolutions.empty?)
    p("returning the ok space")
    return possibleSolutions.at(Random.rand(possibleSolutions.size) % possibleSolutions.size)
  end
  p("no spaces found")
  return nil
end

def nearEnemyBuilding(unit)
  buildingIsNear = false
  spaceArr = genMoveRange2(unit)
  for space in spaceArr
    if(space.terrain.class == City && space.terrain.occoupiedPlayer != unit.commander && space.occoupiedWM == nil)
      buildingIsNear = true
    end
  end
  p("spaces found? " + buildingIsNear.to_s)
  return buildingIsNear
end

def getEnemyBuildingsInArea(unit)
  spaceArr = genMoveRange2(unit)
  buildingSpaces = []
  for space in spaceArr
    if(space.terrain.class == City && space.terrain.occoupiedPlayer != unit.commander && space.occoupiedWM == nil)
      buildingSpaces << space
    end
  end
  return buildingSpaces
end

def getAllEnemyBuildings(currentCommander, allCommanders)
  enemyCities=[]
  for commander in allCommanders
    if(commander != currentCommander)
      enemyCities.concat(commander.citySpaces)
    end
  end
  return enemyCities
end

def tryCapturing(unit)
  p("getting the city path")
  pathToCity = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord), 500, getEnemyBuildingsInArea(unit), unit),[]).reverse
  p("got city path, moving")
  move(unit, pathToCity)
  p("moved, capping")
  terrain = pathToCity.last.terrain
  commanderUnderSiege = terrain.occoupiedPlayer
  isCapital = terrain.conquer(unit)
  if(isCapital)
    destroyAllUnits(commanderUnderSiege)
  end
end

def goToEnemyCity(unit) #I've become so lazy. Well, I should refactor the retreat method to be more general,
  #but still, this is unforgivable =D
  retreat(unit, getAllEnemyBuildings(unit.commander, @listOfP))
end

def unitNeedsSupply(unit)
  wm = nil
  for space in genMoveRange2(unit)
    wm = space.occoupiedWM
    if(wm != nil && wm.commander == unit.commander && wm.needsSupply())
      return wm
    end
  end
  return wm
end

def deliverUnitToCity(unit)
  isClose = false
  pathToCity = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord), 500, getEnemyBuildingsInArea(unit), unit),[]).reverse
  targetCity = pathToCity.last
  unitPath = getAsFarAsPossible(unit,pathToCity,unit.movement)
  if(genMoveRange(unit,(unit.movement + unit.convoyedUnit.movement),@field.getSpace(unit.getCord)).include?(targetCity))
    isClose = true
    targetSpace = refactorBestPath(unit,unitPath,2)
  else
    targetSpace = refactorBestPath(unit,unitPath,1)
  end
  if(targetSpace != nil)
    unitPath = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord), unit.movement, [targetSpace], unit),[]).reverse
  end

  if(unitPath.size > 0)
    move(unit, unitPath)
  end

  if(isClose)
    targetDeploySpace = nil
    spacesAndWeight = calcClosestSpace(deployableSpots(unit.x,unit.y,unit.class), targetCity).reverse
    for space in spacesAndWeight
      if space.at(0).occoupiedWM == nil
        targetDeploySpace = space.at(0)
      end
    end
    unitToDeploy = unit.deploy
    p("targetDeployspace: " + targetDeploySpace.class.to_s)
    unitToDeploy.setCord(targetDeploySpace.getCord.at(0), targetDeploySpace.getCord.at(1))
    @field.addWM(unitToDeploy)
    @sprites << unitToDeploy
  end

end

def getAsFarAsPossible(unit, pathToCity, movement)
  i = 0
  unitPath = []
  mvmt = movement
  while mvmt > 0 #this basically gets the unit as far as it can get on the whole path
    if(i >= pathToCity.size)
      mvmt = 0
    else
      citySpace = pathToCity.at(i)
      if (citySpace.terrain.movement <= mvmt || (unit.isFlying && mvmt > 0))
        p("gonna add the space, mvmt:" + mvmt.to_s + ", spaceMvmt:" + citySpace.terrain.movement.to_s)
        unitPath << pathToCity.at(i)
        if(unit.isFlying)
          mvmt = mvmt - 1
        else
          mvmt = mvmt - citySpace.terrain.movement
        end
        i = i + 1
      else
        p("not gonna add the space")
        mvmt = 0
      end
    end
  end
  return unitPath
end

def supplyNearbyUnit(unit,supplyUnit)
  unitIsSupplied = false
  retreat(unit,getNeighboringSpaces(supplyUnit.space))
  spaces = getNeighboringSpaces(unit.space)
  for space in spaces
    if space.occoupiedWM == supplyUnit
      unit.supply(supplyUnit)
      unitIsSupplied = true
    end
  end
  if(!unitIsSupplied)
    nextUnit = nil
    for space in spaces
      if space.ouccoupiedWM != nil && nextUnit == nil
        nextUnit = space.occoupiedWM

      elsif space.occoupiedWM != nil && nextUnit != nil
        if(space.occoupiedWM.fuel *1.0/(space.occoupiedWM.maxFuel*1.0)) > (nextUnit.fuel*1.0/nextUnit.maxFuel*1.0) || (space.occoupiedWM.ammo *1.0 / (space.occoupiedWM.maxAmmo *1.0)) > (nextUnit.ammo*1.0 / nextUnit.maxAmmo*1.0)
          nextUnit = space.occoupiedWM
        end
      end
    end
    if(nextUnit != nil)
      supply(nextUnit)
    end
  end
end

def findInf(unit, currentPlayer)
  units = currentPlayer.units.dup
  p("num units total:" + currentPlayer.units.size.to_s)
  infSpaces = units.delete_if{|x| x.class != Infantry && x.class != Mech}
  p("num units total:" + currentPlayer.units.size.to_s)
  retreat(unit,infSpaces)
end

def nearOpenTransport(inf, currentPlayer)
  infSpaces = genMoveRange2(inf)
  p("num units total:" + currentPlayer.units.size.to_s)
  for unit in currentPlayer.units
    p("currentplayer unit:" + unit.class.to_s)
  end
  units = currentPlayer.units.dup
  transportUnits = units.delete_if{|x| x.class != APC && x.class != TChopper && x.class != Lander}
  p("num transport units:" + transportUnits.size.to_s)
  p("num units total:" + currentPlayer.units.size.to_s)
    openUnits = Hash.new()
  possibleTransports = []
  for unit in transportUnits
    
    if unit.hasRoom
      p("convoy unit has room!")
      openUnits[unit] = @field.getSpace(unit.getCord)
    end
  end
  openUnits.each{|unit,space|
    if(infSpaces.include?(space))
      p("found a possible transport!")
      possibleTransports << unit
    end
  }

  if(possibleTransports.size > 0)
    return possibleTransports.at(Random.rand(2) % possibleTransports.length)
  else
    p("no transports found")
    return nil
  end
end

def joinTransport(unit,transport)
  theMovementPath = genPathFromNodes(optimizeMovePath(@field.getSpace(unit.getCord),unit.movement,[@field.getSpace(transport.getCord)],unit), []).reverse
  move(unit,theMovementPath)
  transport.convoy(unit)
  @sprites.delete(unit)
  @field.removeWM(unit)
end

#################Mechanics###########################################

def tmpField(cords)
  listOfCords = @field.listOfCords()
  tmpSpaceArr = []
  for n in cords
    if(listOfCords.include?(n))
      tmpSpaceArr.concat([@field.getSpace(n)])
    end
  end
  for n in tmpSpaceArr
    n.toggleTmpSpace()
  end
  #@field.printField()
  for n in tmpSpaceArr
    n.toggleTmpSpace()
  end

end

def selectUnit(currentPlayer)
  x=(@mapx/2)
  y=(@mapy/2)
  currentSpace = @field.getSpace([y,x]) #was 0,0
  tmpSpace = nil
  spotSelected = false
  currentSpace.toggleIsCursor()
  @sprites << currentSpace
  warMachine = nil
  @infoBar.modifyText("Select a unit. move:(w,s,a,d), select:(f), goBack:(x)")
  #@field.printField
  while !spotSelected
    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    if(currentSpace.occoupiedWM) #Used in console and to set the WM for loop
      if(currentPlayer.isUnit(currentSpace.occoupiedWM))
        warMachine = currentSpace.occoupiedWM
        updateConsole(currentSpace.terrain,currentSpace.occoupiedWM,nil,nil)
      else
        warMachine = nil
        updateConsole(currentSpace.terrain,nil,currentSpace.occoupiedWM,nil)
      end
    else
      updateConsole(currentSpace.terrain,nil,nil,nil)
    end
    @event_queue.each do |event|
      case event
      when Events::QuitRequested
        throw :rubygame_quit
      when Events::KeyPressed
        puts("keypressed " + event.to_s)
        if(event.key == :s)

          tmpSpace = @field.getSpace([currentSpace.x+1, currentSpace.y]) ##Down
          if (tmpSpace == nil )
            p("DNE")
          else

            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
            p(currentSpace.getCord)
          end
        elsif(event.key == :w)
          tmpSpace = @field.getSpace([currentSpace.x-1, currentSpace.y]) ##Up
          if (tmpSpace == nil )
            p("DNE")
          else

            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
            p(currentSpace.getCord)
          end
        elsif(event.key == :a)
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y-1]) ##Left
          if (tmpSpace == nil )
            p("DNE")
          else

            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
            p(currentSpace.getCord)
          end
        elsif(event.key == :d)
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y+1]) ##Right
          if (tmpSpace == nil )
            p("DNE")
          else

            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
            p(currentSpace.getCord)
          end
        elsif(event.key == :f)
          ## ###Causing extra curser glitch?
          if(currentSpace.occoupiedWM && warMachine != nil && currentPlayer.isUnit(warMachine) && !warMachine.hasMoved) #is the WM part of the current player?
            p("exit condition was successful")
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            warMachine = currentSpace.occoupiedWM
            spotSelected = true
          elsif(isOpenFactory(currentSpace,currentPlayer))
            p("yep, all is well! ")
            buildNewUnit(currentPlayer, currentSpace.terrain, currentSpace.terrain.createableUnits)
          end
        elsif(event.key == :x)
          ## ###Causing extra curser glitch?
          currentSpace.toggleIsCursor()
          @sprites.delete(currentSpace)
          warMachine = nil
          spotSelected = true
        else
          @infoBar.modifyText("Select a unit. move:(w,s,a,d), select:(f), goBack:(x)")
        end

      end
    end

  end
  return warMachine
end

def isOpenFactory(space,currentPlayer)
  terrain = space.terrain#check type for different buildings too, also tmpOcc may not matter, cant recall =]
  return (terrain.class == City && terrain.occoupiedPlayer == currentPlayer && (terrain.typeNumber == 2 || terrain.typeNumber == 3 ||  terrain.typeNumber == 4) && space.occoupiedWM == nil && space.tmpOccoupiedWM == nil)
end

def buildNewUnit(currentPlayer, factory, createableUnits)
  unitSelected = false
  x = 0
  pair = createableUnits.at(x)
  @infoBar.modifyText("<=(a)  Unit: "+ pair.at(0) + "  Cost: "+ pair.at(1).to_s + " (d)=>, (s) to select")
  while(!unitSelected)

    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      when Events::QuitRequested
        throw :rubygame_quit
      when Events::KeyPressed
        if(event.key == :a)
          if(x == 0)
            x = createableUnits.length()-1
          else
            x -= 1
          end
          pair = createableUnits.at(x)
          @infoBar.modifyText("<=(a)  Unit: "+ pair.at(0) + "  Cost: "+ pair.at(1).to_s + " (d)=>, (s) to select")
        elsif(event.key == :d)
          if(x == createableUnits.length()-1)
            x = 0
          else
            x += 1
          end
          pair = createableUnits.at(x)
          @infoBar.modifyText("<=(a)  Unit: "+ pair.at(0) + "  Cost: "+ pair.at(1).to_s + " (d)=>, (s) to select")
        elsif(event.key == :s)
          if(currentPlayer.funds - pair.at(1) >= 0)
            newUnit = Kernel.const_get(pair.at(0)).new(factory.y,factory.x,currentPlayer.playerNum)
            currentPlayer.addUnits([newUnit])
            @sprites << newUnit
            @field.addWM(newUnit)
            newUnit.setHasMoved()
            p("current players funds: " + currentPlayer.funds.to_s)
            currentPlayer.decreaseFunds(pair.at(1))
            p("current players funds now: " + currentPlayer.funds.to_s)
            unitSelected = true
          end
        elsif(event.key == :x)
          unitSelected = true
        end
      end
    end
  end
end

#call this for each unit in the warmachine
def deployableSpots(wMX, wMY, unitClass)
  spaceArr = [
    @field.getSpace([wMX+1, wMY]),
    @field.getSpace([wMX, wMY+1]),
    @field.getSpace([wMX-1, wMY]),
    @field.getSpace([wMX, wMY-1])
  ]

  return spaceArr.delete_if{|space| space == nil || space.terrain.class == Sea || (space.terrain.class == Mountain && unitClass.class != (Infantry || Mech)) || space.occoupiedWM != nil}
end

def deploy(unit, unitToDeploy)

  @infoBar.modifyText("Select the space where you want to deploy: cycle (a) left and (d) right, (f) to select")
  deployableSpaces = deployableSpots(unit.x, unit.y, unitToDeploy.class)
  x = 0
  tmpSpace = deployableSpaces.at(x)
  tmpSpace.toggleIsCursor()
  @sprites << tmpSpace

  unselected = true
  while(unselected)
    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      when Events::QuitRequested
        throw :rubygame_quit
      when Events:: KeyPressed
        if(event.key == :a)
          if(x == 0)
            x = deployableSpaces.length() - 1
          else
            x -= 1
          end
          @sprites.delete(tmpSpace)
          tmpSpace.toggleIsCursor()
          tmpSpace = deployableSpaces.at(x)
          tmpSpace.toggleIsCursor()
          @sprites << tmpSpace
        elsif(event.key == :d)
          if(x == deployableSpaces.length() - 1)
            x = 0
          else
            x += 1
          end
          @sprites.delete(tmpSpace)
          tmpSpace.toggleIsCursor()
          tmpSpace = deployableSpaces.at(x)
          tmpSpace.toggleIsCursor()
          @sprites << tmpSpace
        elsif(event.key == :f)
          unselected = false
          @sprites.delete(tmpSpace)
          tmpSpace.toggleIsCursor()
        end
      end
    end

  end

  unitToDeploy.setCord(tmpSpace.getCord.at(0), tmpSpace.getCord.at(1))
  @field.addWM(unitToDeploy)
  @sprites << unitToDeploy
end

def openAdjacentLand(warMachine)
  if(@field.getSpace([warMachine.x+1, warMachine.y]).terrain.class != Sea && @field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM == nil)
    return true
  end
  if(@field.getSpace([warMachine.x-1, warMachine.y]).terrain.class != Sea && @field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM == nil)
    return true
  end
  if(@field.getSpace([warMachine.x, warMachine.y+1]).terrain.class != Sea && @field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM == nil)
    return true
  end
  if(@field.getSpace([warMachine.x, warMachine.y-1]).terrain.class != Sea && @field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM == nil)
    return true
  end
  return false
end

def neighboringFriendlyUnits(warMachine)
  listOfUnits = []
  if(@field.getSpace([warMachine.x+1, warMachine.y]) != nil && \
  @field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM != nil)
    listOfUnits.concat([@field.getSpace([warMachine.x+1, warMachine.y]).occoupiedWM])
  end
  if(@field.getSpace([warMachine.x-1, warMachine.y]) != nil && \
  @field.getSpace([warMachine.x-1, warMachine.y]).occoupiedWM != nil)
    listOfUnits.concat([@field.getSpace([warMachine.x-1, warMachine.y]).occoupiedWM])
  end
  if( @field.getSpace([warMachine.x, warMachine.y+1]) != nil && \
  @field.getSpace([warMachine.x, warMachine.y+1]).occoupiedWM != nil)
    listOfUnits.concat([@field.getSpace([warMachine.x, warMachine.y+1]).occoupiedWM])
  end
  if(@field.getSpace([warMachine.x, warMachine.y-1]) != nil && \
  @field.getSpace([warMachine.x, warMachine.y-1]).occoupiedWM != nil)
    listOfUnits.concat([@field.getSpace([warMachine.x, warMachine.y-1]).occoupiedWM])
  end
  for unit in listOfUnits
    if unit.commander != warMachine.commander
      listOfUnits.delete(unit)
    end
  end

end

def getCommand(currentPlayer)
  unAnswered = true
  @infoBar.modifyText("(s)elect unit or (e)nd turn?")
  while unAnswered

    seconds_passed = @clock.tick().seconds
    for player in @listOfP
      if player.units.empty?
        @listOfP.delete(player)
      end
    end
    if(@listOfP.length == 1)
      unAnswered = false
    end
    @event_queue.each do |event|
      case event
      when Events::KeyPressed
        if(event.key == :s)
          wM = selectUnit(currentPlayer)
          if(wM != nil)
            currentCords = wM.getCord()
            move(wM, movePath(wM)) #Generates the movement for unit/moves and sets unit
            unitAction(wM,currentPlayer,currentCords) #takes the updated unit (new position) and asks what it'll do
          else
            @infoBar.modifyText("(s)elect unit or (e)nd turn?")
          end
        elsif(event.key == :e)
          unAnswered = false
        else
          @infoBar.modifyText("(s)elect unit or (e)nd turn?")
        end
      end
    end

    update(seconds_passed)

  end
end

def parseCommands(commandList)
  str = ""
  for command in commandList
    str += "(" + command[0].to_s + ")" + command[1..-1].to_s + " "
  end
  return str
end

def genPossibleCommands(warMachine,commandList, currentPlayer)
  possibleCommands = ["xgo back"]
  if(@field.getSpace(warMachine.getCord).tmpOccoupiedWM) #space has 2 WMs (the already residing wm, and current wm as tmp)
    if(commandList.include?("join") || (@field.getSpace(warMachine.getCord).occoupiedWM.class == Lander && (!warMachine.isFlying  && !warMachine.isSailing)))
      if(@field.getSpace(warMachine.getCord).occoupiedWM.unitCommands.include?("deploy"))
        if(@field.getSpace(warMachine.getCord).occoupiedWM.hasRoom())
          possibleCommands.concat(["join"])
        end
      end
    end
    if(warMachine.class == @field.getSpace(warMachine.getCord).occoupiedWM.class && warMachine.health < 10 && @field.getSpace(warMachine.getCord).occoupiedWM.health < 10)
      p("can combine")
      possibleCommands.concat(["ucombine"])
    end

  else #space isn't occoupied by any other wm
    if(commandList.include?("attack"))
      if(!(warMachine.hasMoved && !warMachine.isDirect))
        attackableWMs = attackableWarMachines(genRange(warMachine.attackRange,warMachine.getCord),currentPlayer, warMachine) #returns a list of WMs in range
        if(!attackableWMs.empty?)
          possibleCommands.concat(["attack"])
        end
      end
    end
    if(commandList.include?("wait"))
      possibleCommands.concat(["wait"])
    end
    if(commandList.include?("supply"))
      if(!neighboringFriendlyUnits(warMachine).empty?)
        possibleCommands.concat(["supply"])
      end
    end
    if(commandList.include?("capture"))
      terrain = @field.getSpace([warMachine.x, warMachine.y]).terrain
      if( terrain.class == City)
        if(((warMachine.class == Infantry  ||  warMachine.class == Mech)) && terrain.occoupiedPlayer != warMachine.commander)
          possibleCommands.concat(["capture"])
        end
      end
    end
    if(commandList.include?("rise/dive"))
      if(warMachine.submerged)
        possibleCommands.concat(["rise"])
      else
        possibleCommands.concat(["rdive"])
      end
    end
    if(commandList.include?("deploy"))
      if(warMachine.hasDeployableUnits())
        tmpArr = []
        for convoyedUnit in warMachine.convoyedUnits
          tmpArr.concat(deployableSpots(warMachine.x,warMachine.y,convoyedUnit.class))
        end
        if(!tmpArr.empty?)
          possibleCommands.concat(["deploy"])
        end
      end
    end
  end
  return possibleCommands
end

def unitAction(warMachine, currentPlayer, previousCords)
  unAnswered = true
  cmdList = genPossibleCommands(warMachine,warMachine.unitCommands,currentPlayer)
  @infoBar.modifyText(parseCommands(cmdList))

  rangeArr = genRange(warMachine.attackRange, @field.getSpace([warMachine.x, warMachine.y]).getCord)
  for space in rangeArr
    space.toggleIsCursor()
    @sprites << space
  end
  while unAnswered

    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      #ADD QUIT EVENT
      when Events::KeyPressed
        if(event.key == :a)
          if(cmdList.include?("attack"))
            attackableWMs = attackableWarMachines(genRange(warMachine.attackRange,warMachine.getCord),currentPlayer, warMachine) #returns a list of WMs in range
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            attack(warMachine, selectTarget(warMachine,attackableWMs),currentPlayer)
            warMachine.setHasMoved()
            unAnswered = false
          end
        elsif(event.key == :w)
          if(cmdList.include?("wait"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            warMachine.setHasMoved()
            unAnswered = false
          end
          ###need to edit till rise
        elsif(event.key == :j)
          if(cmdList.include?("join"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            warMachine.setHasMoved()
            @field.getSpace(warMachine.getCord).occoupiedWM.convoy(warMachine)
            @sprites.delete(warMachine)
            @field.removeWM(warMachine)
            unAnswered = false
          end
        elsif(event.key == :d)
          if(cmdList.include?("deploy"))
            #tmpWarMachine = warMachine.deploy()
            #UPDATE MOVEMENT

            #@field.addWM(tmpWarMachine)
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end

            deploy(warMachine, warMachine.deploy)
            warMachine.setHasMoved()
            unAnswered = false
          end
        elsif(event.key == :u)
          if(cmdList.include?("ucombine"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end

            heal(@field.getSpace(warMachine.getCord).occoupiedWM, warMachine.health)
            warMachine.destroyed()
            #warMachine.setHasMoved()
            (warMachine.commander).removeUnit(warMachine)
            @sprites.delete(warMachine)
            @field.removeWM(warMachine)
            unAnswered = false
          end
        elsif(event.key == :s)
          if(cmdList.include?("supply"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            warMachine.setHasMoved()
            unAnswered = false
          end
        elsif(event.key == :r)
          if(cmdList.include?("rdive"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            warMachine.toggleSubmerged() #will toggle it to true
            warMachine.setHasMoved()
            unAnswered = false
          end
        elsif(event.key == :r)
          if(cmdList.include?("rise"))
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            warMachine.toggleSubmerged() #will toggle it to false
            warMachine.setHasMoved()
            unAnswered = false
          end

          ##
        elsif(event.key == :c)
          if(cmdList.include?("capture"))
            p("trying to capture")
            terrain = @field.getSpace([warMachine.x, warMachine.y]).terrain
            p("The terrain is a city")
            for space in rangeArr
              space.toggleIsCursor()
              @sprites.delete(space)
            end
            commanderUnderSiege = terrain.occoupiedPlayer
            isCapital = terrain.conquer(warMachine)
            if(isCapital)
              destroyAllUnits(commanderUnderSiege)
            end
            warMachine.setHasMoved()
            unAnswered = false
          end
        elsif(event.key == :x)#go back
          for space in rangeArr
            space.toggleIsCursor()
            @sprites.delete(space)
          end

          @field.removeWM(warMachine)
          warMachine.setCord(previousCords.at(0),previousCords.at(1))
          @field.addWM(warMachine)

          warMachine.setUnmoved()
          unAnswered = false
        end
      end
    end
  end
  @infoBar.modifyText("(s)elect unit or (e)nd turn?")
  updateConsole(nil,nil,nil,nil)
end

def nextPlayerPosition(x) #returns the position of the next person in the listOfP array
  if x==@listOfP.length()-1
    return 0
  else
    return x+1
  end
end

def setUnitsUnmoved(currentPlayer)
  unitsSetToMoved = []
  for unit in currentPlayer.units
    if(unit.unitCommands.include?("deploy") && unit.hasDeployableUnits())
      unitsSetToMoved.concat(unit.convoyedUnits)
    end
    unit.setUnmoved()
  end
  #this is done because ending turn may require all units to be set to moved, so convoyed units
  #could be an issue if registered as unmoved
  for unit in unitsSetToMoved
    unit.setHasMoved()
  end
end

def update(seconds_passed)
  #@sprites.undraw @screen, @background
  # Give all of the sprites an opportunity to move themselves to a new location
  @sprites.update  seconds_passed
  # Draw all of the sprites
  @sprites.draw @screen
  @screen.flip
end

#May have to augment this method when there are 'bosses', or keep it in mind
def heal(unit, ammount)
  if(unit.health + ammount <= 10)
    unit.incHealth(ammount)
  else
    unit.incHealth((10 - unit.health))
  end
end

def preTurnActions(player) # does various things that occur before a turn, such as heal units
  terrain = nil
  player.acquireFunds()
  p("current funds: " + player.funds.to_s)
  for unit in player.units
    terrain = @field.getSpace([unit.x, unit.y]).terrain
    if( terrain.class == City)
      p("The terrain is indeed a city")
      if(terrain.occoupiedPlayer == player)
        p("doin stuff for unit")
        heal(unit, 2)
        unit.restockAmmo()
        unit.restockFuel()
      end
    end
    if(unit.isFlying)
      p("flying unit")
      p("decresing fuel")
      unit.decTurnFuel() #only accessable for .isFlying units (currently)
      p("fuel is " + unit.fuel.to_s)
      if(unit.fuel < 1)
        @sprites.delete(unit)
        unit.destroyed()
        explosion(unit.y, unit.x)
        (unit.commander).removeUnit(unit)
        @field.removeWM(unit)
      end
    end
  end
end

def updateConsole(terrain,playerWM,target,damagePercentage)
  @sprites.delete(@console)
  @console.modify(terrain,playerWM,target,damagePercentage)
  @sprites << @console
end

def updateConsoleLockUnit(terrain,target,damagePercentage)
  @sprites.delete(@console)
  @console.modifyUnitLocked(terrain,target,damagePercentage)
  @sprites << @console
end

def main()
  setup(true)

  x = 0
  currentPlayer = @listOfP.at(x)

  preTurnActions(currentPlayer)
  #  theRocket = Rocket.new(0,2,2) For testing how well the path finder is
  #  @sprites << theRocket
  #  @listOfP.at(1).addUnits([theRocket])
  #  move(theRocket, genPathFromNodes(optimizeMovePath(@field.getSpace(theRocket.getCord),99,@field.getSpace([1,18]),theRocket),[]))

  while (@listOfP.length() != 1)

    seconds_passed = @clock.tick().seconds

    @event_queue.each do |event|
      case event
      when Events::QuitRequested, Events::KeyReleased
        should_run = false
      end
    end
    preTurnActions(currentPlayer)
    if(currentPlayer.class.to_s != "AI")
      getCommand(currentPlayer)
    else
      ######### A I Implementation ####
      @dangerZones = getAllDangerZones(currentPlayer)
      sortedUnits = currentPlayer.units.sort{|a,b| b.cost <=> a.cost }
      for unit in sortedUnits
        p("The current unit:" + unit.class.to_s)
        didAction = false
        #If already capturing, keep capturing
        if(!didAction && (unit.class == Mech || unit.class == Infantry) && @field.getSpace(unit.getCord).terrain.class == City && @field.getSpace(unit.getCord).terrain.occoupiedPlayer != unit.commander && @field.getSpace(unit.getCord).terrain.cityLevel < 20 )
          terrain = @field.getSpace(unit.getCord).terrain
          commanderUnderSiege = terrain.occoupiedPlayer
          isCapital = terrain.conquer(unit)
          if(isCapital)
            destroyAllUnits(commanderUnderSiege)
          end
          didAction = true
        elsif(!didAction && (unit.class == Mech || unit.class == Infantry) && nearEnemyBuilding(unit) )
          tryCapturing(unit)
          didAction = true
          #the next part needs to be rethought-perhapse a 'pick a choice and stick with it' attribute for WMs
          #otherwise they would just always cap or attack or retreat =(
        elsif(!didAction && (unit.class == Mech || unit.class == Infantry)) #and no good attack outcomes!!!
          transport = nearOpenTransport(unit,currentPlayer)
          if(transport != nil)
            joinTransport(unit,transport)
          else
            goToEnemyCity(unit)
          end
          didAction = true
        elsif(!didAction && unit.class == APC)
          p("APC is up")
          supplyUnit = unitNeedsSupply(unit)
          if(unit.convoyedUnit != nil)
            p("delivering unit to city!")
            deliverUnitToCity(unit)
          elsif(supplyUnit != nil)
            p("supplying unit!")
            supplyNearbyUnit(unit,supplyUnit)
          else
            p("finding inf!")
            findInf(unit, currentPlayer)
          end
          didAction = true
        elsif(!didAction && unit.health < 4)
          retreat(unit, currentPlayer.citySpaces)
          didAction = true
        elsif(!didAction)
          attackUnit(unit, currentPlayer)
          didAction = true
        end

      end
      p("number of remaning units:" + currentPlayer.units.size.to_s)

    end
    if(@listOfP.length() > 1)
      @infoBar.modifyText(currentPlayer.name + " eneded their turn")
      setUnitsUnmoved(currentPlayer)
      x = nextPlayerPosition(x)
      currentPlayer =  @listOfP.at(x)
      #      t1 = Time.new()
      #      p("time1:" + t1.to_s)
      #
      #      t2 = Time.new()
      #      ("time2:" + t2.to_s)
      p("the next player is " + currentPlayer.name)
      for player in @listOfP
        if player.units.empty?
          @listOfP.delete(player)
        end
      end
    end
    update(seconds_passed)

  end

  @infoBar.modifyText(@listOfP.at(0).name + " WINS!")
  unAnswered = false
  while !unAnswered

    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
    @event_queue.each do |event|
      case event
      #ADD QUIT EVENT
      when Events::KeyPressed
        unAnswered = true
      end
    end
  end
end

=begin
attack(tank,mTank)
p("MedTank")
p(mTank.health)
p(mTank.power)
p("Tank")
p(tank.health)
p(tank.power)

attack(mTank,tank)
p("MedTank")
p(mTank.health)
p(mTank.power)
p("Tank")
p(tank.health)
p(tank.power)

p(genRange([3, 5], [0,0]).include?([0,-5]))

p("Initial")
p("Rocket")
p(rocket.health)
p(rocket.power)
p("Artillery")
p(art.health)
p(art.power)

p("rocket attacking artillery")
inRange(rocket, art)
p("Rocket")
p(rocket.health)
p(rocket.power)
p("Artillery")
p(art.health)
p(art.power)

p("artillery attacking rocket")
inRange(art, rocket)
p("Rocket")
p(rocket.health)
p(rocket.power)
p("Artillery")
p(art.health)
p(art.power)

=end

puts ("move the tank!")
#move(mTank, movePath(mTank))
#@field.printField()
#p(genRange([2,3],[5,5]))
#tmpField(genRange([2,3],[5,5]))

main()

