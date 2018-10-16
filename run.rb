
############################################################################
#                             Global Variables                             #
# ##########################################################################

Nodes=[] #Constant because of capital

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
  attr_reader :name, :parents, :parMap, :prob

  def initialize(name)
    @name = name
    @parents=nil
    @parMap=nil
    @prob=nil
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
    @parMap= Array.new(2**parameters.split(',').length){Array.new(parameters.split(',').length)}
    (2**(parameters.split(',').length)).times do |t|
      bin = '%0*b' % [parameters.split(',').length , t]
      parameters.split(',').length.times do |ite|
        @parMap[t][ite]=bin[ite]
      end
    end

    #Initialize probabilities table to nil
    @prob=Array.new(2**parameters.split(',').length){Array.new(2)}
    @prob.each {|p| p=nil}

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
          if @parMap[caso][i].to_i != lookArray[i].to_i
            f = false
          end
        end
      end
      if @parents.length == 1
        if @parMap[caso][0].to_i != lookArray.to_i
          f = false
        end
      end
      if
        if sign=='+'
          @prob[caso][0]=probability
          @prob[caso][1]=1.0 -probability
        else
          @prob[caso][0]=1.0 -probability
          @prob[caso][1]=probability
        end
      end
    end
    #puts @Prob
    #puts @name
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
        if @parMap[caso][i].to_i != lookArray[i].to_i
          f = false
        end
      end
    end
    if @parents.length == 1
      if @parMap[caso][0].to_i != lookArray.to_i
        f = false
      end
    end
    if f
      if sign=='+'
        return @prob[caso][0]
      else
        return @prob[caso][1]
      end
    end
  end
end

end

#####################################################################################

def get_antecesors(node_name, ret_arr)
  Nodes.each do |n|
    if n.get_Name == node_name
      if n.get_Parents.length == 0
        ret_arr.push(n.get_Name).uniq!
        return
      else
        n.get_Parents.each do |n2|
          f = true
          if ret_arr.length > 0
            ret_arr.each do |che|
              if n2.get_Name == che
                f = false
              end
              if f
                get_antecesors(n2.get_Name, ret_arr)
              end
            end
          else
            get_antecesors(n2.get_Name, ret_arr)
          end
          ret_arr.push(node_name).uniq!
        end
      end
    end
  end
end

def set_CPT(prob,number)
  if prob.include? '|'  #Is a given
    assign=prob.split('|')
    sign=assign[0][0]
    node_Name= assign[0].gsub(/\+/,'').gsub(/-/,'')
    Nodes.each do |n|                 #     This cycle will help us to find
      if n.get_Name == node_Name      #  the node we are trying to modify.
        #puts "Im now on node #{n.name}"
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

def get_Probability(prob, pdis) #In the form +G|-R,+S
  if prob.include? '|'  #To check if we have a given
    search = prob.split('|') #Obtain elements in an array of [[+G],[-R,+S]]
    sign = search[0][0] #To obtain the sign of the node
    node_Name = search[0].gsub(/\+/,'').gsub(/-/,'') #To remove any sign that can exist
    joints = search[1].gsub(/\+/,'').gsub(/-/,'').split(',')
    antn = []
    antd = []
    Nodes.each do |n|                 #This cycle will help us to find the node we are trying to modify
      if n.get_Name == node_Name      #To find the node given in the probability 'prob'
        #puts "Estoy en el nodo: #{node_Name}"
        #Get the antecesors of the node to be able to apply total probability
        #puts "Sin antecesores: #{antn}"
        get_antecesors(node_Name, antn);
        #Apply total probability for the nodes in search[0]
        #puts "Con antecesores: #{antn}"
        #puts "Numerator: "
        num = totalProb(antn, pdis); #[+G,-S,+R]
        #puts "Numerator is #{num}"
        #puts "Sin antecesores: #{antd}"
        get_antecesors(joints[0], antd);
        #puts "Con antecesores: #{antd}"
        #puts "Denominator"
        denom = totalProb(antd, pdis); #[-S,+R]
        #puts "Denominator is #{denom}"
        return num/denom #Obtain the probability of the division P(+G,-R,+S)/P(-R,+S)
      end
    end
  else  #Root
    sign = prob[0][0] #To obtain the sign of the +G
    node_Name= prob.gsub(/\+/,'').gsub(/-/,'') #Remove signs and leave G alone
    Nodes.each do |n| #Obtain the node from the array
      if n.get_Name == node_Name #If we have a match
        return n.search_Prob(sign,"") #Return the probability of the root
      end
    end
  end
end

def totalProb(query, pdis)#[+G,-S,+R]
  #puts "Query = #{query} and pdis = #{pdis}"
  sum = 1
  root = []
  query.each do |q| #Go trough the query nodes
    Nodes.each do |n| #Go trough the nodes
      if q == n.get_Name #To find the node
        if n.get_Parents.length == 0
          sum *= n.search_Prob(q[0], "")
        else
          temp = pdis.dup #What the use is looking fo, for example: +G,-R
          #puts "Temporal: #{temp}"
          #puts "Nodo actual #{n.get_Name}"
          #puts "Arreglo actual = #{temp}"
          temp.reject!{|b| root.push(b); b.include?(n.name)} #Delete the root node
          #puts "Arreglo nuevo = #{temp}"
          if n.get_Parents.length != temp.length #Were missing parents to be considered, so we apply enumeration algoritm
            sum += enume(root, pdis)
          else #We're all set, and so we just obtain the probabilities
            sum *= n.search_Prob(q[0], temp.join(",")) 
          end
        end
      end
    end
  end
  sum
end

def enume(root, query)#+G,-R
  sum = 0
  queryns = []
  added = []
  count = 0
  query.each do |e|
    queryns.push(e.gsub(/\+/,'').gsub(/-/,'') ) 
  end
  #puts "New: #{queryns}"
  Nodes.each do |n| #Go trough the nodes
    #puts "Node: #{n.get_Name}"
    queryns.each do |q| #Go through the array
      #puts "Query element: #{q}"
      if n.get_Name == q #Found the array I wanted
        #puts "Coincidence in #{n.get_Name} and #{q}"
        n.parents.each do |p|
          #puts "Mi padre es: #{p.get_Name}"
          if q != p.get_Name #Go through the parents to determine 
            added.push(p.get_Name).uniq! #Add the missing elements
            count += 1
          end
        end
      end
    end
  end
  uni = added - queryns
  #puts "New elements: #{added} old elements #{queryns} supposely good: #{uni}"
  #Obtain the probability of the elements with opposite signs
  #added -> Nodos antecesores no contemplados
  #query -> Nodos iniciales con signos
  str = query.join(",") + ","
  j = 0
  count.times do |i| #Recorrer el número de veces que necesito para formar todas las combinaciones posibles
    uni.each do |a| #Recorrer cada elemento nuevo
      if j % 2 == 0
        sum += chain_rule(str+"+"+a)
      else
        sum += chain_rule("-"+a)
      end
    end
  end
  sum
  #puts "Nuevo total probability: #{str}"
  #puts "Nuevos elementos: #{queryns}"
end

def chain_rule(string)
  prod = 1
  nuevo = []
  #puts "Elementos: #{string.gsub(/ /, '').split(",")}"
  proba = string.gsub(/ /, '').split(",") #In the form of [+G, -R, +S] on first iteration
  proba.each do |ele|
    Nodes.each do |n|
      if n.get_Name == ele.gsub(/\+/,'').gsub(/-/,'')
        #Check size of parent
        order(nuevo, proba) #Ordena el arreglo por orden cantidad de padres
        #puts "Hasta ahorita: #{string.sub(',', "|")}"
      end
    end
  end
  #nuevo es un arreglo con los nodos ordenados por cantidad de padres
  s = nuevo.join(",") #Obtengo +G,+S,-R
  s.sub!(",", "|") #Obtengo +G|+S,-R
  arr = s.split("|") #Obtengo ["+G","+S,-R"]
  #puts "Vamos bien: #{arr}"
  nuevo.each do |nu|
    Nodes.each do |n|
      if n.get_Name == nu.gsub(/\+/,'').gsub(/-/,'')
        if arr.length > 1
          #puts "Voy a querer obtener el nodo: #{n.get_Name} con signo #{nu[0]} y joints #{arr[1]}"
          prod *= n.search_Prob(nu[0], arr[1])
          #puts "Probabilidad de: #{prod}"
          arr = arr.drop(1) #Obtengo [+S -R]
          #puts "Hasta ahorita #{arr.join(",").sub!(",", "|").split("|")}"
        else
          #Obtener la probabilidad de sólo 1 nodo
        end
      end
    end
  end
  #puts "Chain rule probability: #{prod}"
  prod
end

def order(nuevo, arr) #Order the array in terms of its parents
  temp = 0
  temparr = []
  arr.each do |a|
    Nodes.each do |n|
      if n.get_Name == a.gsub(/\+/,'').gsub(/-/,'')
        temp = n.get_Parents.length
        temparr << [temp, a]
      end
    end
  end
  #puts "Arreglo de arreglos sin ordenar: #{temparr}"
  temparr.sort_by! {|i| i.first }.reverse!
  #puts "Arreglo de arreglos ordenados: #{temparr}"
  temparr.each do |t|
    nuevo.push(t[1]).uniq!
  end
  #puts "Arreglo final: #{nuevo}"
end

############################################################################
#                                Main program                              #
# ##########################################################################

var_names = gets.chomp.gsub(/ /,'').split(',')
var_names.each {|i| Nodes.push Node.new(i)}

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
  #Como validar si la probabilidad ya la tengo para regresarla directo
  pdis = line.gsub(/\|/, ',').split(',')
  puts get_Probability(line, pdis)
end

#puts "What you entered was #{info}" #Adds a new line (enter) to the text
