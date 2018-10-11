#print "Something to digest: " #Prints without a new line

Nodes=[]

############################################################################
#                                                                          #
#                               Class Node                                 #
#                                                                          #
# ##########################################################################
#                                                                          #
#     The following class uses Nodes as a Global variable.                 #
#     Each node has a string name, a array of parents and 2 matrix:        #
#         - @P = Matrix which will hold the map of different combiantions  #
#    of true and false that my parents can have.                           #
#         - @Probs = Matrix that holds the probabilities that the current  #
#     node can happen, this bases on the row of the mapping matrix (@P)    #
#     [column 0 means the prob that can happen while column 1 the opposite]#
#                                                                          #
############################################################################
class Node
  attr_reader :name, :parents, :ParMap, :Prob

  def initialize(name)
    @name = name
    @parents=nil
    @ParMap=nil
    @Prob=nil
  end

  def get_Name()
    @name
  end

  def get_Parents
    @parents
  end

  #################################
  #       Initialize a Node       #
  #################################
  def set_New_Node(parameters)

    #Initialize mapping table
    @ParMap=Array.new(2**parameters.split(',').length){Array.new(parameters.split(',').length)}
    (2**(parameters.split(',').length)).times do |t|
      bin = '%0*b' % [parameters.split(',').length , t]
      parameters.split(',').length.times do |ite|
        @ParMap[t][ite]=bin[ite]
      end
    end

    #Initialize probabilities table to nil
    @Prob=Array.new(2**parameters.split(',').length){Array.new(2)}
    @Prob.each {|p| p=nil}

    #Assign parent nodes
    @parents=[]
    parameters.gsub(/\+/,'').gsub(/-/,'').split(',').each do |par_name|
      Nodes.each do |n|
        if n.get_Name == par_name
          @parents.push n
        end
      end
    end
  end

  #################################################################
  #       Function that takes the sign of the probability         #
  #     that something will happen, the parameters are the        #
  #     string of the conditional and the probability the         #
  #     probability that the node will happen                     #
  #################################################################
  def assign_Prob(sign,parameters,probability)
    if @parents.length > 1
      lookArray = Array.new(parameters.split(',').length)
      parameters.split(',').each do |par_name|
        parSign = par_name[0]
        parName = par_name.gsub(/\+/,'').gsub(/-/,'')
        Nodes.length.times do |nodePosition|
            if Nodes[nodePosition].get_Name == parName
              if parSign == '+'
                lookArray[nodePosition] = 1;
              else
                lookArray[nodePosition] = 0;
              end
            end
        end
      end
    end
    if @parents.length == 1
      parameters.split(',').each do |par_name|
        parSign = par_name[0]
        parName = par_name.gsub(/\+/,'').gsub(/-/,'')
        Nodes.length.times do |nodePosition|
          if Nodes[nodePosition].get_Name == parName
            if parSign == '+'
              lookArray= 1;
            else
              lookArray= 0;
            end
          end
        end
      end
    end
    (2**@parents.length).times  do |caso|
      f=true
      if @parents.length > 1
          @parents.length.times do |i|
          if @ParMap[caso][i].to_i != lookArray[i].to_i
            f = false
          end
        end
      end
      if @parents.length == 1
        if @ParMap[caso][0].to_i != lookArray.to_i
          f = false
          end
      end
      if f
        if sign=='+'
          @Prob[caso][0]=probability
          @Prob[caso][1]=1-probability
        else
          @Prob[caso][0]=1-probability
          @Prob[caso][1]=probability
        end
      end
    end
    puts @Prob
    puts @name
  end
end

#####################################################################################


def set_CPT(prob,number)
  if prob.include? '|'  #Is a given
    assign=prob.split('|')
    sign=assign[0][0]
    node_Name= assign[0].gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|                 #   This cycle will help us to find the
      if n.get_Name == node_Name      #the node we are trying to modify.

        if n.get_Parents == nil #Node has not been initialized (so initialize it haha)
          n.set_New_Node(assign[1])
        end
        n.assign_Prob(sign,assign[1],number)

      end
    end
  else                  #Root
    sign=prob[0][0]
    node_Name= prob.gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|
      if n.get_Name == node_Name
        if n.get_Parents == nil
          n.set_New_Node("")
        end
        n.assign_Prob(sign,"",number)

      end
    end
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