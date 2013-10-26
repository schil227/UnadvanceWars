Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    require file
  end}

@mfuel = 99
@fuel = 15

def needsFuel()
  return (@fuel*1.0)/(@mfuel*1.0) < 0.2
end


p("need fuel?" + needsFuel().to_s)

@fuel = 55

p("need fuel?" + needsFuel().to_s)