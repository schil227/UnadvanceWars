Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    require file
  end}

  size = 10 
  arr = ["a", "b","c","d",2 ,4,"m",5]
    
    p((arr.size*1.0)/(size *1.0))
    
arr2 = arr.delete_if{|x| x.class != String}
  p("new arr:" + arr2.to_s)
