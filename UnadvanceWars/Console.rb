require "rubygems"
require "rubygame"

include Rubygame

class Console
  include Sprites::Sprite
  def initialize(xCord,maxYCord)
    super()
    TTF.setup
    #Main output groups

    @xCord = xCord
    @battleDataC = "Battle Data"
    @terrainC = "Terrain"
    @unitC = "Unit"
    @targetC = "Target"

    #Subgroups

    #terrain
    @tTypeC = " Type: "
    @tDefC = " Defense: "
    #unit
    @uTypeC = " Type: "
    @uHealthC = " Health: "
    @uAmmoC = " Ammo: "
    @uFuelC = " Fuel: "
    @uMovementC = " Movement: "
    #Enemy
    @eTypeC = " Type: "
    @eHealthC =" Health: "
    @eDamagePotentialC = " Dam % :"

    @timeSum = 0
    @stepBool = false
  end

  def modify(terrain, playerWM, target, damagePercent)
    if(terrain != nil)
      @tTypeC = " Type: " + terrain.class.to_s
      @tDefC = " Defense: " + terrain.defence.to_s
    else
      @tTypeC = " Type: "
      @tDefC = " Defense: "
    end
    if(playerWM != nil)
      @uTypeC = " Type: " + playerWM.class.to_s
      @uHealthC = " Health: " + playerWM.health.to_s
      @uAmmoC = " Ammo: "+ playerWM.ammo.to_s
      @uFuelC = " Fuel: "+ playerWM.fuel.to_s
      @uMovementC = " Movement: "+ playerWM.movement.to_s
    else
      @uTypeC = " Type: "
      @uHealthC = " Health: "
      @uAmmoC = " Ammo: "
      @uFuelC = " Fuel: "
      @uMovementC = " Movement: "
    end
    if(target != nil)
      @eTypeC = " Type: "+ target.class.to_s
      @eHealthC =" Health: "+ target.health.to_s
      if(damagePercent != nil)
        @eDamagePotentialC = " Dam % :" + damagePercent.to_S
      end
    else
      @eTypeC = " Type: "
      @eHealthC =" Health: "
      @eDamagePotentialC = " Dam % :"
    end

  end

  def modifyUnitLocked(terrain, target, damagePercent)
    if(terrain != nil)
      @tTypeC = " Type: " + terrain.class.to_s
      @tDefC = " Defense: " + terrain.defence.to_s
    else
      @tTypeC = " Type: "
      @tDefC = " Defense: "
    end
    if(target != nil)
      @eTypeC = " Type: "+ target.class.to_s
      @eHealthC =" Health: "+ target.health.to_s
      if(damagePercent != nil)
        @eDamagePotentialC = " Dam % :" + (((damagePercent*1000).to_i)/100).to_s
      end
    else
      @eTypeC = " Type: "
      @eHealthC =" Health: "
      @eDamagePotentialC = " Dam % :"
    end

  end
  
  def update(seconds_passed) #blinking effect for warning text?
    #    @timeSum += seconds_passed
    #       if(@timeSum >= 5)
    #         @timeSum = 0
    #         if(@stepBool)
    #           @battleDataC = "Battle Data"
    #         else
    #           @battleDataC = "GAAAAAH Data"
    #         end
    #         @stepBool = !@stepBool
    #       end
  end

  def draw(on_surface)

    consoleBackground = Surface.load("data/background.png")

    $font = TTF.new("data/WHITRABT.ttf", 25)
    battleData = $font.render(@battleDataC.to_s,true, [0,0,0])
    terrian  = $font.render(@terrainC.to_s, true, [0,0,0])
    unit  = $font.render(@unitC.to_s, true, [0,0,0])
    target  = $font.render(@targetC.to_s, true, [0,0,0])

    $fontC = TTF.new("data/WHITRABT.ttf", 20)
    #terrain
    tType = $font.render(@tTypeC,true, [0,0,0])
    tDef = $font.render(@tDefC,true, [0,0,0])
    #units
    uType  = $font.render(@uTypeC ,true, [0,0,0])
    uHealth  = $font.render(@uHealthC ,true, [0,0,0])
    uAmmo = $font.render(@uAmmoC ,true, [0,0,0])
    uFuel =$font.render(@uFuelC ,true, [0,0,0])
    uMovement  =$font.render(@uMovementC  ,true, [0,0,0])
    #Enemy (target)
    eType  =$font.render(@eTypeC   ,true, [0,0,0])
    eHealth  =$font.render(@eHealthC  ,true, [0,0,0])
    eDamagePotential  =$font.render(@eDamagePotentialC  ,true, [0,0,0])

    consoleRect =consoleBackground.make_rect()
    consoleRect.topleft = [@xCord-5,0]

    spacer = 4

    consoleBackground.blit(on_surface, consoleRect)
    battleData.blit(on_surface, [@xCord, 5])
    terrian.blit(on_surface, [@xCord, 25])
    tType.blit(on_surface, [@xCord, 40+spacer*2])
    tDef.blit(on_surface, [@xCord, 55+spacer*3])
    unit.blit(on_surface, [@xCord, 70+spacer*4+20])
    uType.blit(on_surface, [@xCord, 90+spacer*5 +20])
    uHealth.blit(on_surface, [@xCord, 105+spacer*6 +20])
    uAmmo.blit(on_surface, [@xCord, 120+spacer*7 +20])
    uFuel.blit(on_surface, [@xCord, 135+spacer*8 +20])
    uMovement.blit(on_surface, [@xCord, 150+spacer*9 +20])
    target.blit(on_surface, [@xCord, 165+spacer*10 +40])
    eType.blit(on_surface, [@xCord, 185+spacer*11+40])
    eHealth.blit(on_surface, [@xCord, 200+spacer*12+40])
    eDamagePotential.blit(on_surface, [@xCord, 215+spacer*13+40])

    #    @image.blit(on_surface,@rect)
    #    @imageTerrain.blit(on_surface, @rectTerrain)
    #    @imageUnit.blit(on_surface,@imageUnit)
  end

end
