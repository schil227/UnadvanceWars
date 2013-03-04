#!/usr/bin/ruby
Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb")
    require file
  end}

require 'rubygems'
require 'rubygame'

include Rubygame

file = File.open("data/map1.txt",'r')
@mapx = file.read.count("\n")
file.rewind
@mapy = file.readline().size - 1
@field = Field.new(@mapx, @mapy) #x & y are flipped D:
@field.setupField()

@screen = Screen.open [ @mapx * 50, @mapy *50]
@clock = Clock.new
@clock.target_framerate = 60
@clock.enable_tick_events
@background = Surface.load "data/background.png"
@background.blit @screen, [ 0, 0]

Sound.autoload_dirs = [ File.dirname(__FILE__) ]
@explosionSound = Sound['data/explosion.wav']
@explosionSound.volume = 0.25

@sprites = Sprites::Group.new
Sprites::UpdateGroup.extend_object @sprites

for space in @field.sfield
  @sprites.concat([space.terrain])
end

@event_queue = EventQueue.new
@event_queue.enable_new_style_events
p1Units = [
  mTank = MedTank.new(5,5,1),
  art = Artillery.new(2,3,1),
  tank2 = Tank.new(0,4,1),
  inf = Infantry.new(6,7,1),
  chop = BChopper.new(5,8,1),
  bat = Battleship.new(3,11,1),
  bomb = Bomber.new(3,7,1),
  crsr = Cruiser.new(3,10,1),
  recon1 = Recon.new(2,8,1),
  mech1 = Mech.new(2,9,1),
  apc = APC.new(6,8,1),
  lan = Lander.new(6,11,1)
]

p2Units = [
  mTank2 = MedTank.new(6,5,2),
  tank = Tank.new(1,3,2),
  art2 = Artillery.new(0,1,2),
  art3 = Artillery.new(1,1,2),
  rocket = Rocket.new(0,2,2),
  aa = AntiAir.new(1,6,2),
  fgtr = Fighter.new(2,14,2),
  sub = Submarine.new(2,11,2),
  recon = Recon.new(3,9,2),
  mech = Mech.new(1,9,2),
]

player1 = Player.new("uno",1)
player2 = Player.new("dos",2)

@listOfP = [player1,player2]

player1.addUnits(p1Units)
player2.addUnits(p2Units)

for u in player1.units
  @field.addWM(u)
  @sprites << u
end

for u in player2.units
  @field.addWM(u)
  @sprites << u
end

###Combat###
def attack(attacker, attacked,currentPlayer)
  p("before attack:")
  p("Attaking " + attacker.class.to_s + " health: " + (attacker.health).to_s)
  p("Defending " + attacked.class.to_s + " health: " + (attacked.health).to_s)
  attacked.decHealth(calcDamage(attacker,attacked)) #would add land def here
  if(attacked.health > 0 && attacker.isDirect && attacked.isDirect) #counter attack, D v D only
    attacker.decHealth(calcDamage(attacked,attacker))
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

def calcDamage(attacker, attacked)
  attackPower = 0
  if(attacker.ammo > 0 && attacker.attackTable[attacked.symb] != nil)
    attacker.decAmmo
    attackPower = attacker.attackTable[attacked.symb] * (attacker.power)
  elsif( defined?(attacker.secondaryAttackTable))
    if(attacker.secondaryAttackTable[attacked.symb] != nil)
      attackPower = attacker.secondaryAttackTable[attacked.symb] * (attacker.power)
    end
  else
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

def selectTarget(attackableWMs) #cycles 'left' and 'right' through the list of attackable WMs
  if(attackableWMs.length() == 1)
    return attackableWMs.at(0)
  end

  p("Select The machine you want to attack: cycle (a) left and (d) right, (f) to select")
  x = 0
  currentWM = attackableWMs.at(x)
  currentWMSpace = @field.getSpace([currentWM.x, currentWM.y])

  currentWMSpace.toggleIsCursor()
  @sprites << currentWMSpace

  unselected = true
  while unselected
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
          p("Select The machine you want to attack: cycle (a) left and (b) right, (f) to select")
        end
      end
    end
  end
  return currentWM
end

###Movement###

def genMoveRange(warMachine)
  spaceArr = []
  currentSpace = @field.getSpace(warMachine.getCord)
  spaceArr.concat(genSpaceMovement(currentSpace, warMachine.movement, spaceArr, warMachine))

  for space in spaceArr
    space.resetSpaceMvmt
  end
  return spaceArr.uniq()
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

def move(warMachine, spaces) #animation, setting/unsetting spaces
  timeSum = 0
  moving = true
  spaceArr = spaces.reverse
  while moving
    seconds_passed = @clock.tick().seconds

    timeSum += seconds_passed*10
    if(timeSum > 5 && warMachine.fuel > 0)
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

  tmpArr = genMoveRange(warMachine)
  for space in tmpArr
    space.toggleIsCursor()
    @sprites << space
  end

  p("Move the War Machine using w,s,a,d and (f) to select")
  tmpField([currentSpace.getCord()])
  while true
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
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
          end
        elsif(event.key == :w)#259
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x-1, currentSpace.y])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
          end
        elsif(event.key == :a)#260
          warMachine.setHasMoved()
          tmpSpace = @field.getSpace([currentSpace.x, currentSpace.y-1])
          if(tmpArr.include?(tmpSpace))
            currentSpace.toggleIsCursor()
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
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
            @sprites.delete(currentSpace)
            currentSpace = tmpSpace
            currentSpace.toggleIsCursor()
            @sprites << currentSpace
          end

        elsif(event.key == :f)
          spotSelected = true
          spaceArr.concat([currentSpace])
        else
          p("Move the War Machine using w,s,a,d and (f) to select")
        end
      end
    end
    if(spotSelected)
      currentSpace.toggleIsCursor()
      @sprites.delete(currentSpace)
      break
    end

    #tmpField([currentSpace.getCord()])

  end

  for space in tmpArr
    space.setIsCursorFalse()
    @sprites.delete(space)
  end

  return spaceArr
end

#################Mechanics###########################################

def timeStep()
  sleep(0.25)
end

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
  puts("Select a unit to move: use w,s,a,d to control up, down, left, right and (f) to select or (x) to cancel")
  #@field.printField
  while true
    seconds_passed = @clock.tick().seconds
    update(seconds_passed)
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
          end
        elsif(event.key == :f)
          ## ###Causing extra curser glitch?
          if(currentSpace.occoupiedWM) #is a WM on this space?
            if(currentPlayer.isUnit(currentSpace.occoupiedWM) && !currentSpace.occoupiedWM.hasMoved) #is the WM part of the current player?
              currentSpace.toggleIsCursor()
              @sprites.delete(currentSpace)
              warMachine = currentSpace.occoupiedWM
              spotSelected = true
            end
          end
        elsif(event.key == :x)
          ## ###Causing extra curser glitch?
              currentSpace.toggleIsCursor()
              @sprites.delete(currentSpace)
              warMachine = nil
              spotSelected = true
        else
          puts("Select a unit to move: use w,s,a,d to control up, down, left, right and (f) to select or (x) to cancel")
        end
      end
    end

    if(spotSelected)
      break
    end

  end

  return warMachine
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

#Rough cut of deploy: currently returns the first open spot in the deployableSpots list (usually the south spot)
def deploy(unit, unitToDeploy)

  p("Select the space where you want to deploy: cycle (a) left and (d) right, (f) to select")
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
  p("(s)elect unit or (e)nd turn?")
  while unAnswered

    seconds_passed = @clock.tick().seconds

    @event_queue.each do |event|
      case event
      when Events::KeyPressed
        if(event.key == :s)
          if(currentPlayer.hasUnusedUnits())
            wM = selectUnit(currentPlayer)
            if(wM != nil)
              currentCords = wM.getCord()
              move(wM, movePath(wM)) #Generates the movement for unit/moves and sets unit
              unitAction(wM,currentPlayer,currentCords) #takes the updated unit (new position) and asks what it'll do
            end
          end
        elsif(event.key == :e)
          unAnswered = false
        else
          p("(s)elect unit or (e)nd turn?")
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
        if((warMachine.class == (Infantry  ||  Mech)) && terrain.occoupiedPlayer != warMachine.commander)
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
  p(parseCommands(cmdList))

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
            attack(warMachine, selectTarget(attackableWMs),currentPlayer)
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
            terrain.conquer(warMachine)
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
  @sprites.undraw @screen, @background

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

def main()
  x = 0
  currentPlayer = @listOfP.at(x)

  preTurnActions(currentPlayer)

  while (@listOfP.length() != 1)

    seconds_passed = @clock.tick().seconds

    @event_queue.each do |event|
      case event
      when Events::QuitRequested, Events::KeyReleased
        should_run = false
      end
    end

    preTurnActions(currentPlayer)
    getCommand(currentPlayer)
    p(currentPlayer.name + " eneded their turn")
    setUnitsUnmoved(currentPlayer)
    x = nextPlayerPosition(x)
    currentPlayer =  @listOfP.at(x)
    p("the next player is " + currentPlayer.name)
    for player in @listOfP
      if player.units.empty?
        @listOfP.delete(player)
      end
    end

    update(seconds_passed)

  end

  p(@listOfP.at(0).name + " WINS!")

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

