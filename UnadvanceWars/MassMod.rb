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
#    str = "@health = 10"
#    toAdd = "@health = 10 \n\t @healthImage = (Surface.load \"data/blank.gif\") \n "
    
# str = "@health = @health+num"
#   toAdd = "@health = @health+num \n\t healthNum = @health.ceil \n\t if(healthNum != 0 || healthNum != 10) \n\t\t @healthImage = (Surface.load \"data/\" + healthNum.to_s + \".gif\") \n\t else \n\t\t @healthImage = (Surface.load \"data/blank.gif\") \n\t end \n\t"

#        str = "@image.blit  on_surface, @rect"
#    toAdd = "@image.blit  on_surface, @rect \n\t @healthImage.blit  on_surface, @rect "
   
    
str = "healthNum > 0 || healthNum < 10"
toAdd = "healthNum > 0 && healthNum < 10" 

    
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
