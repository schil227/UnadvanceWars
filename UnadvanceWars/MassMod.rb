files = []
wmFiles = []
Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    files << file
  end}

for file in files
  f = File.open(file,'r')
  text = f.read()
  str = /@ammo = \d+/.match(text)
  if(str != nil)
    str = str[0]
    p"The str:"+ str
    num = /\d+/.match(str)[0]
    toAdd = "@ammo = " + num + " \n\t @maxammo = " + num
    text = text.gsub(str,toAdd)
    p(text)
    File.open(file,'w') do |out|
      out << text 
    end
  end
end

#getting  @fuel:  @fuel = \d+
#the number: \d+ on above match
#
#@insertTxt = "@mfuel = " + num

#and needs the method too
