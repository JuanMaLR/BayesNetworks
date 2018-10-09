#print "Something to digest: " #Prints without a new line

Nodes=[]

class Node
  attr_reader :name, :parents, :P, :Prob

  def initialize(name)
    @name = name
    @parents=nil
    @P=nil
    @Prob=nil
  end

  def get_Name()
    @name
  end

  def get_Parents
    @parents
  end

  #Initialize a Node with at least one parent
  def set_New_Node_WP(sign,par,num)

    #Initialize mapping table
    @P=Array.new(2**par.split(',').length){Array.new(par.split(',').length)}
    (2**(par.split(',').length)).times do |t|
      bin = '%0*b' % [par.split(',').length , t]
      par.split(',').length.times do |ite|
        @P[t][ite]=bin[ite]
      end
    end

    #Initialize probabilities table
    @Prob=[2**par.split(',').length][2]
    #@Prob.each {|p| p=nil}

    #Assign parent nodes
    @parents=[]
    par.gsub(/\+/,'').gsub(/-/,'').split(',').each do |par_name|
      Nodes.each do |n|
        if n.get_Name == par_name
          @parents.push n
        end
      end
    end

   (2**@parents.length).times do |caso|
     @parents.length.times do |padre|
       puts @P[caso][padre] + "-" + @parents[padre].get_Name
     end
   end

  end
end

def set_CPT(prob,number)
  if prob.include? '|'  #Is a given
    assign=prob.split('|')
    sign=assign[0][0]
    node_Name= assign[0].gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|
      if n.get_Name == node_Name
        if n.get_Parents == nil
          n.set_New_Node_WP(sign,assign[1],number)
        end
      end
    end
  else                  #Root
    puts "\t" + prob
  end
end

Var_names = gets.chomp.gsub(/ /,'').split(',')
Var_names.each {|i| Nodes.push Node.new(i)}

numP = gets.chomp
probs=[]
numP.to_i.times do
  probs.push gets.chomp
end

numQ = gets.chomp
query=[]
numQ.to_i.times do
  query.push gets.chomp
end

probs.each do |line|
  auxL = line.gsub(/ /,'').split('=')
  set_CPT(auxL[0],auxL[1].to_f)

end


line = probs
#puts "What you entered was #{info}" #Adds a new line (enter) to the text