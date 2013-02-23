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