Dir["./*.rb"].each {|file|
  if (file != "./Main.rb" && file != "./asdf.rb" && file != "./asdf2.rb" &&  file != "./textEx.rb")
    require file
  end}

  size = 10 
  arr = ["a", "b","c","d"]
    
    p((arr.size*1.0)/(size *1.0))
