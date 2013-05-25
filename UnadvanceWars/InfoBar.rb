require "rubygems"
require "rubygame"

include Rubygame

class InfoBar
  include Sprites::Sprite
  def initialize(yCord)
    super()
    TTF.setup
    #Main output groups

    @yCord = yCord
    @battleDataC = "Welcome to UnadvaceWars"
  end

  def modifyText(infoText)
    @battleDataC = infoText
  end

  def update(seconds_passed)
    
  end

  def draw(on_surface)

    infoBackground = Surface.load("data/background.png")

    $font = TTF.new("data/WHITRABT.ttf", 25)
    battleData = $font.render(@battleDataC.to_s,true, [0,0,0])
    
  infoRect =infoBackground.make_rect()
  infoRect.topleft = [5,@yCord+3]
        
  infoBackground.blit(on_surface, infoRect)
  battleData.blit(on_surface, [5,@yCord+3])

  end

end
