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
      if f
        if sign=='+'
          @prob[caso][0]=probability
          @prob[caso][1]=(1.0 -probability).round(3)
        else
          @prob[caso][0]=1.0 -(probability).round(3)
          @prob[caso][1]=probability
        end
      end
    end
    #puts @prob
    #puts @name
  end


  def search_Prob(sign,parameters)
    if parameters.split(',').length != @parents.length
      return false
    end
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
    return false
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

=begin
@param {string} node_name - Name of the node -- Sprinkler
@param {array} arr - Array (without roor) with nodes ordered respect to their parents to be verified if they're dependent or not -- ["-Grasswet", "+Sprinkler", "-Rain"]
@param {array} pdis - Array with all nodes to be considered with sign (not ordered) -- ["+Sprinkler", "-Rain"]
=end
def verify_Antecesors (node_name, arr, pdis)
  #puts "El nombre de mi nodo es: #{node_name} y mi arreglo es: #{arr} y mi distribución de pdis es: #{pdis}"
  temp = []
  Nodes.each do |n|
    if n.get_Name == node_name
      if n.get_Parents.length != arr.length
        #puts "Longitud de mis padres: #{n.get_Parents.length} y de mi arreglo: #{arr.length}"
        n.get_Parents.each do |p|
          #Get all the parents without sing from the root node (node_name)
          temp.push(p.get_Name)
        end
      end
    end
  end
  #puts "El padre de #{node_name} es: #{temp}"
  #puts "Hasta ahora amigos tenemos como arreglo principal: #{arr} y como arreglo temporal: #{temp}, cuya resta da #{arr-temp}"
  nuev = []
  #For each parent node
  temp.each do |t|
    #puts "Verifica si funciona: #{arr.join(',').include? t}"
    #temp.reject!{|b| root.push(b).uniq!; b.include?(n.name)} #Delete the root node
    #Check if the array includes already the name of the parent node
    #puts "Incluye mi distribución a mi nodo padre? #{pdis.join(',').include? t }"
    if pdis.join(',').include? t 
      #puts "Entonces entro aquí y funciono? #{pdis.select{|ele| ele.include? t}}"
      #If it includes it (ignoring the sign) then add that node (with sign) to the new array (nuev)
      nuev.push(pdis.select{|ele| ele.include? t})
    end
  end
  #puts "Lo que tengo en mi nodo de padres es: #{arr} y lo que tengo en mi nodo raiz con signo es: #{nuev}" 
  #puts "Estoy haciendo: #{nuev.join(',') + temp.join(',')}"
  #arr = (pdis.select{|ele| ele.include? node_name}.join(',')+','+nuev.join(',')).split(',')
  nuev.join(',').split(',')
  #arr.push(node_name)
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
##################################################################
# This will return immediately in case the prob is in the tables #
##################################################################
#If it´s a given
  if prob.include? '|'
    #Name our search variable
    search = prob.split('|')
    #if I have just one value in the prob
    #puts "Esta checando #{search[0].split(',').length}"
    if search[0].split(',').length == 1
      #To obtain the sign of the node
      sign = search[0][0]
      # #Remove sign from the node
      node_Name = search[0].gsub(/\+/,'').gsub(/-/,'')
      #Obtain the node from the array
      Nodes.each do |n|
        #If we have a match
        if n.get_Name == node_Name
          if n.search_Prob(sign,search[1]) != false
             #puts "No debo entrar aquí"
            return n.search_Prob(sign,search[1])
          else
            if search[1].split(',').length == 1
              num = enume(pdis); 
              denom = enume(prob.split('|')[1].split(',')); 
              return num/denom 
            else
              arri = search[0].split(",")
              abaj = search[1].split(",")
              #puts "Arriba: #{arri}, abajo: #{abaj}"
              #puts "Denominator: #{enume(abaj)}"
              num = enume(arri)
              #puts "Caso a analizar:"
              denom = enume(abaj)
              return num/denom
            end
          end
        end
      end
    else
      #puts "En el elemento 1: #{search[0]} y en el elemento 2: #{search[1]}"
      arri = search[0].split(",")
      abaj = search[1].split(",")
      #puts "Arriba: #{arri}, abajo: #{abaj}"
      return enume(arri)/enume(abaj)
    end
  else
    #It is not a given
    sign = prob[0]
    ant = []
    # #Remove sign from the node
    node_Name= prob.gsub(/\+/,'').gsub(/-/,'')
    #Obtain the node from the array
    Nodes.each do |n|
      #If we have a match
      if n.get_Name == node_Name
        if n.search_Prob(sign,"") != false
          return n.search_Prob(sign,"")
        else
          get_antecesors(node_Name, ant)
          verify_Antecesors(node_Name, ant, pdis)
          return totalProb(ant, pdis)
        end
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
        #puts "El nodo es: #{n.get_Name} y la cantidad es: #{n.get_Parents.length}"
        if query.length == 1 && n.get_Parents.length == 0
          #puts "nodo: #{n.get_Name} and query: #{query} and parents #{n.get_Parents.length}"
          #puts "La forma en que lo tengo es: #{pdis[0][0]}"
          return n.search_Prob(pdis[0], "")
          #puts "Esto me está dando mal: #{sum}"
        else
          temp = pdis.dup #What the use is looking fo, for example: +G,-R
          #puts "Temporal: #{temp}"
          #puts "Nodo actual #{n.get_Name}"
          #puts "Arreglo actual = #{temp}"
          temp.reject!{|b| root.push(b).uniq!; b.include?(n.name)} #Delete the root node
          #puts "Arreglo nuevo = #{temp}"
          if n.get_Parents.length != temp.length #Were missing parents to be considered, so we apply enumeration algoritm
            #puts "So far, so good, with root being: #{root} and pdis: #{pdis}"
            #puts "HOLIIIIII"
            #puts "Sum: #{sum}"
            return enume(pdis)
          else #We're all set, and so we just obtain the probabilities
            #puts "Do we appear here?"
            return n.search_Prob(q[0], temp.join(",")) 
          end
        end
      end
    end
  end
  #puts "Tu tienes: #{sum}"
end

def enume(query)#+G,-R       CORRECT!!!!!!
  #puts "Mi query en enum: #{query}"
  sum = 0
  queryns = []
  added = []
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
        #n.parents.each do |p|
          #puts "Mi padre es: #{p.get_Name}"
          #puts "Entro 1 vez"
          #if q != p.get_Name #Go through the parents to obtain what to be used as substraction to obtain only the elements for sumation
            #added.push(p.get_Name).uniq!
            #queryns.push(p.get_Name).uniq! 
            #puts "Nuevo arreglo: #{queryns}"
          #end
        #end
        get_antecesors(n.get_Name, added)
      end
    end
  end
  #puts "Que tengo: #{added} y acá #{queryns}"
  uni = added - queryns
  #puts "New elements: #{added} old elements #{queryns} supposely good: #{uni}"
  #Obtain the probability of the elements with opposite signs
  #added -> Nodos antecesores no contemplados
  #query -> Nodos iniciales con signos
  #puts "Mi query es: #{query}"
  #puts "counts: #{count} and uni: #{uni}"
  (2**uni.length).times do |i| #Recorrer el número de veces que necesito para formar todas las combinaciones posibles
    bin = '%0*b' % [uni.length , i]
    #puts bin
    str = query.join(",")
    uni.length.times do |j| #Recorrer cada elemento nuevo
      #puts "Ponte sólo 1 vez"
      if bin[j] == '0'
        #puts "Mandando #{str+"+"+a}"
        #puts "Positive turn"
        str = str + ", +" + uni[j]
      else
        #puts "Mandando #{str+"-"+a}"
        #puts "Negative turn"
        str = str + ", -" + uni[j]
      end
    end
    #puts "Lo que mando #{str}"
    sum += chain_rule(str)
  end
  #puts "La suma de mis valores da: #{sum}"
  sum
  #puts "Nuevo total probability: #{str}"
  #puts "Nuevos elementos: #{queryns}"
end

def chain_rule(string) #Correct!!!!!!
  #puts "Tengo ahorita: #{string}"
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
#puts "Lo nuevo que tengo es: #{nuevo}"
  s = nuevo.join(",") #Obtengo +G,+S,-R
  s.sub!(",", "|") #Obtengo +G|+S,-R
  arr = s.split("|") #Obtengo ["+G","+S,-R"]
  nuevo.each do |nu|
    Nodes.each do |n|
      if n.get_Name == nu.gsub(/\+/,'').gsub(/-/,'')
        #puts "Los nombres de mis nodos a analizar son: #{n.get_Name}"
        if arr.length > 1 && n.get_Parents.length != 0
          if n.search_Prob(nu[0], arr[1]) != false
            prod *= n.search_Prob(nu[0], arr[1])
            arr = arr.drop(1) 
            arr = arr.join(",").split(",")
          else
            #arr -- ["+Alarm", "+JohnCalls,+Burglary,+Earthquake"]
            temp = arr.dup
            #Deleting the root node from the temporal array -- ["+JohnCalls,+Burglary,+Earthquake"]
            temp.reject!{|b| b.include?(n.name)}
            #Rearrange the array so that each element is on one position -- ["+JohnCalls" , "+Burglary" , "+Earthquake"]
            temp = temp.join(',').split(',')
            #Redifine array by deleting the unwanted nodes -- ["+Burglary" , "+Earthquake"]
            temp = verify_Antecesors(n.get_Name, temp, nuevo) 
            #puts "Para mi nodo: #{n.get_Name} mis antecesores son: #{temp}"
            #puts "La probabilidad de mi nodo: #{n.get_Name} con signo: #{nu[0]} y joint: #{temp.join(',')} es: #{n.search_Prob(nu[0], temp.join(','))}"
            prod *= n.search_Prob(nu[0], temp.join(','))
            #Delete array first element of arr -- ["+JohnCalls,+Burglary,+Earthquake"]
            arr = arr.drop(1) 
            #Obtain a two element array to know which node will be analyzed next ["+JohnCalls" , "+Burglary,+Earthquake"]
            arr = arr.join(",").sub!(",", "|").split("|")
          end
        else
          t = arr[0].gsub(/\+/,'').gsub(/-/,'')
          #puts "La probabilidad de mi nodo: #{n.get_Name} es: #{totalProb(Array[t], arr.join(","))}"
          prod *= totalProb(Array[t], arr.join(","))
          if arr.length > 1
            arr = arr.drop(1) #Obtengo [+S -R]
            arr = arr.join(",").split(",")
          end
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

#Nodes.each do |n|
#  if n.get_Name == "Sprinkler"
#    puts "Probando en nodo #{n.get_Name} con signo + y joint -Rain"
#    puts "El valor debería de ser: #{n.search_Prob('+', "-Rain")}"
#  end
#end

#puts "Probando: #{("+GrassWet|-Rain").split("|")}"

query.each do |line|
  #Como validar si la probabilidad ya la tengo para regresarla directo
  pdis = line.gsub(/\|/, ',').split(',')
  puts get_Probability(line, pdis)
end

#puts "What you entered was #{info}" #Adds a new line (enter) to the text