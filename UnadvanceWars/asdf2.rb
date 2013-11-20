Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    require file
  end}

@maxFuel = 99
@fuel = 15
@maxAmmo = 99
@ammo = 15
def needsFuel()
  return (@fuel*1.0)/(@maxFuel*1.0) < 0.2
end

def needsFuel()
  return (@ammo*1.0)/(@maxAmmo*1.0) < 0.2
end

def needsSupply()
  return ((@fuel*1.0)/(@maxFuel*1.0) < 0.2) || ((@ammo*1.0)/(@maxAmmo*1.0) < 0.2)
end

p("need fuel?" + needsFuel().to_s)

@fuel = 55

p("need fuel?" + needsSupply().to_s)

#def incHealth(num)\n    @health = @health+num\n    @power = 10*(@health *0.1)\n  end\n\n
#def incHealth(num)\n    @health = @health+num\n    @power = 10*(@health *0.1)\n  end\n\n    def needsFuel()\n    return (@fuel*1.0)/(@maxFuel*1.0) < 0.2\n  end\n\n     def needsAmmo()\n    return (@ammo*1.0)/(@maxAmmo*1.0) < 0.2\n  end\n\n     def needsSupply()\n    return ((@fuel*1.0)/(@maxFuel*1.0) < 0.2) || ((@ammo*1.0)/(@maxAmmo*1.0) < 0.2)\n  end\n\n