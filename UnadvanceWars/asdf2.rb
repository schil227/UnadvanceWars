Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb"  && file != "./textEx.rb")
    require file
  end}

require 'rubygems'
require 'rubygame'

include Rubygame


file = File.open("data/map1.txt",'r')
terrainArray =[]
for line in file
  for char in line.each_char
    if char != "\n"
      terrainArray << char
    end
  end
end

puts (file.class == File)

while !terrainArray.empty?()
  case terrainArray.pop
  when("")
    puts("itsa one!")
  end

end


book = {'a' => 1, 'b' => 2, 'c' => 3}

p(book['f'])
  
  
p("asdfasdfasdfasdfasdf")
str ="string"
p("(" + str[0].to_s + ")" + str[1..-1].to_s)

boo = (1 == (1 && 1))
p(boo.to_s)

file = File.open("data/map1.txt",'r')
mapx = file.read.count("\n")
file.rewind
mapy = file.readline().size - 1
 
p(mapx)
p(mapy)

a = false
p(a && b)

aList = []
if(aList.empty?)
  p("the list is empty")
else
  p("empty is false")
end

p("new tests")
p(nil && a)

for i in 1..100
  if(i%3 == 0 && i%5 == 0)
    p("FizzBuzz")
  elsif(i%3==0)
    p("Fizz")
    elsif(i%5==0)
      p("Buzz") 
  else
    p(i)
  end
end


lilList = ['a','b','c']
puts("list at 0: " + lilList.at(0))


@landUnitPrices= [["Infantry", 1000], ["Mech", 3000], ["Recon", 4000], ["APC", 5000], ["Tank", 6000], ["Artillery", 7000], ["AntiAir", 8000], ["Missile", 14000], ["Rockets", 15000], ["MedTank", 16000]]

#newTank =  Kernel.const_get("MedTank").new(5,6,2)
##"MedTank".constantize.new(5,6,2)
#@landUnitPrices.each{|key,value|
#  p("<=a  #{key}  #{value}  d=>")
#}
#
#p(newTank)

pair = @landUnitPrices.at(3)
p("<=a  Unit: "+ pair.at(0) + "  Cost: "+ pair.at(1).to_s + " b=>")

p((t.class == MedTank).to_s)