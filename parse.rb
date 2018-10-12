
############################################################################
#                             Global Variables                             #
# ##########################################################################

Nodes=[]
sumnum = 0
sumden = 0

############################################################################
#                                Class Node                                #
# ##########################################################################
#                                                                          #
#     The following class uses Nodes as a Global variable.                 #
#     Each node has a string name, a array of parents and 2 matrix:        #
#         - @P = Matrix which will hold the map of different combinations  #
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
    @ParMap= Array.new(2**parameters.split(',').length){Array.new(parameters.split(',').length)}
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
          @Prob[caso][1]=1.0 -probability
        else
          @Prob[caso][0]=1.0 -probability
          @Prob[caso][1]=probability
        end
      end
    end
    puts @Prob
    puts @name
  end


def search_Prob(sign,parameters)
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
        return @Prob[caso][0]
      else
        return @Prob[caso][1]
      end
    end
  end
end

end

#####################################################################################


def set_CPT(prob,number)
  if prob.include? '|'  #Is a given
    assign=prob.split('|')
    sign=assign[0][0]
    node_Name= assign[0].gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|                 #     This cycle will help us to find
      if n.get_Name == node_Name      #  the node we are trying to modify.
        if n.get_Parents == nil       #     Node has not been initialized.
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

def get_Probability(prob)
  if prob.include? '|'  #Is a given
    search=prob.split('|')
    sign=search[0][0]
    node_Name= search[0].gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|                 #     This cycle will help us to find
      if n.get_Name == node_Name      #  the node we are trying to modify.
        return n.search_Prob(sign,search[1])
      end
    end
  else                  #Root
    sign=prob[0][0]
    node_Name= prob.gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|
      if n.get_Name == node_Name
        return n.search_Prob(sign,"")
      end
    end
  end
end

def ObtQuer(quer)
  nums = []
  #Imagine we obtain P(+Grass|-Sprinkler,+Rain)
  if (quer.split('|').length > 1) #I have a conditional probability
    #I split the left and right parts [[+Grass],[-Sprinkler,+Rain]]
    node = quer.split('|')
    #So I make my conditional probability definition using an array, always first element is joint and second is right side of node
    #First validate if the second part of node is more than 1
    if(node[1].split(',').length > 1)
      #I now know that I have more than 1 element on the right of node
      join = node[0] + ',' + node[1].join(',')
      #I first validate that joint doesn't already includes all nodes in the network
      if join.split(',').length <= numnode 
        #If not I create my conditional probability model
        #join is in the form [+Grass,-Sprinkler,+Rain]
        #node[1] is in the form [-Sprinkler,+Rain]
        CPText = [[join],[node[1]]]
        #Loop to find the parents (atencesors to be used in the enumeration algorithm) of a node
        FindParents(CPText, 0)
        #Now I know what my antecesors are, so I start obtaining the names (probability distribution) of each of the nodes
        FindPDF(sumnum)
      end
      #Now I have the probability of the numerator, so we now found the denominator
      #Find antecesors first
      FindParents(CPText, 1)
      #Find the probability distribution functions as a value sum
      FindPDF(sumden)
      #Divide the elements and return the probability of the query
      return sumnum/sumden ######How to return?
    end
  end
end

def FindPDF(sum)
  Nodes.each do |x|
    if(x.name ) #########Somehow obtain the PD of the node, not its name? And sum them
      sum += x.
  end 
end

def FindParents(CPText, frac)
  CPText[frac].split(',').each do |x|
    #To find the position of node with same name as CPText and use that to obtain the node
    n = nodes[nodes.index(x)]
    #I have the node of Grass, so now I add its parents if any to my array par
    if n.parents != nill
      #Then I do have parents and I add them
      n.parents.each do |y|
        #I add the parent name
        CPText[frac].push(y.name)
      end  
    end
  end
end

############################################################################
#                                Main program                              #
# ##########################################################################

Var_names = gets.chomp.gsub(/ /,'').split(',')
Var_names.each {|i| Nodes.push Node.new(i)}
numnode = Var_names.length

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

query.each do |line|
  puts get_Probability(line)
end

line = probs
puts Nodes
#puts "What you entered was #{info}" #Adds a new line (enter) to the text
