Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb" && file != "./MassMod.rb")
    require file
  end}

#  size = 10
#  arr = ["a", "b","c","d",2 ,4,"m",5]
#
#    p((arr.size*1.0)/(size *1.0))
#
#arr2 = arr.delete_if{|x| x.class != String}
#  p("new arr:" + arr2.to_s)
#
#
#def fib(numTimes, currentNum, prevNum)
#  if(numTimes > 0)
#    return fib(numTimes -1, currentNum + prevNum, currentNum)
#  else
#    return currentNum
#  end
#end
#
#num = 0
#Thread.new {
#      sleep(rand(0)/10.0)
#      Thread.current["mycount"] = count
#      count += 1
#   }

#p("fib: " + fib(1000, 1, 0).to_s)
#num = 0
#t1 = Thread.new{
#  sleep(1)
#  num= fib(10000,1,0)
#}
#while(num == 0 && t1.alive?)
#p("num: " + num.to_s)
#end
#p("end num: " + num.to_s)

#10.times do
#   p("rand: " + Random.rand(5).to_s)
#
#end
#
#p("ah")
#gets()
#p("sure")

h = Hash.new(0)
h['a']= 3
h['b']= 4
h['c']= 2

#p(h.sort_by{|key,val| val}.key.to_s)

#a= [-2, "a"]
#b= [1, "b"]
#c= [-4, "c"]
#arr = [a,b,c].sort{|a,b| a.at(0) <=> b.at(0) }
#n1 = arr.at(2).at(0) - arr.at(1).at(0)
#n2 = (arr.at(1).at(0) - arr.at(0).at(0)) + n1
#p("n1:" + n1.to_s + ", n2:" + n2.to_s)
#p(arr)
#
#n1 = 4
#n2 = 3
#n3 = n1 - n2
#p("n3:" + n3.to_s)
#
#n1 = 4
#n2 = -3
#n3 = n1 - n2
#p("n3:" + n3.to_s)
#
#n1 = -2
#n2 = -3
#n3 = n1 - n2
#p("n3:" + n3.to_s)
#
#n = arr.each{|x|  if x.at(1) == "a"
#  true
#end}
#p("n:" + n.to_s)
#
#n1=0
#n2=0
#
#if(n1 == 0)
#  n1=1
#elsif(n2==0)
#  n2=1
#end
#
#
#p("n1:" + n1.to_s + ", n2:" + n2.to_s)
  
#@UnitCosts = [["Infantry", 1000], ["Mech", 3000], ["Recon", 4000], ["APC", 5000], ["Tank", 6000], ["Artillery", 7000], ["AntiAir", 8000], ["Missile", 14000], ["Rocket", 15000], ["MedTank", 16000], \
#  ["Lander",12000],["Cruiser", 18000],["Submarine",20000],["Battleship", 28000],["TChopper",7000],\
#  ["BChopper",9000],["Fighter", 20000],["Bomber", 22000]]
#possibleUnits = []
#possibleUnits.concat([[Mech,2], [Tank,2], [Artillery,2], [MediumTank,2]])    
   
p("It's hella legit! This'll be the look on the dm's face right before they break my character and I tap my sword of rage and lay down two turns in a row of Berzerk with +6 attack, which with average damage every time would be 12 D a hit with a net total of 72".upcase)