Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
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

10.times do
   p("rand: " + Random.rand(5).to_s)  
  
end

p("ah")
gets()
p("sure")