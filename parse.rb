print "Something to digest: " #Prints without a new line

#info = gets.chomp #To obtain information from the command line
Var_names = gets.chomp.gsub(/ /,'').split(',')
Var_names.each {|i| puts i}

num = gets.chomp
probs=[]
num.to_i.times do
  probs.push gets.chomp
end

num = gets.chomp
query=[]
num.to_i.times do
  query.push gets.chomp
end


#puts "What you entered was #{info}" #Adds a new line (enter) to the text