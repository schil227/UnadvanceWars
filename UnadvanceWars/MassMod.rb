files = []
wmFiles = []
Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    files << file
  end}

for file in files
  f = File.new(file)
  text = f.read()
  str = /@fuel = \d+/.match(text)
  if(str != nil)
    str = str[0]
    p"The str:"+ str
    num = /\d+/.match(str)
    toAdd = "@fuel = " + num + " \n\t @maxFuel = " + num
    text.gsub(str,toAdd)
  end
end

#getting  @fuel:  @fuel = \d+
#the number: \d+ on above match
#
#@insertTxt = "@mfuel = " + num

#and needs the method too
