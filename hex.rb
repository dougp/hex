class Hex
  def initialize
    if rand(3) > 1 then @obstructed=true else @obstructed=nil end
  end 
  def obstructed? 
    @obstructed
  end 
end

class HexBoard 
  def initialize(rows=9, cols=9) 
    @rows, @cols = rows, cols 
    @board = Array.new(@rows) do |row| 
      Array.new(@cols) do |col| 
        Hex.new 
      end 
    end 
  end
  def directions
    [[-1,0], #ne
    [-1,-1], #nw
    [0,1], #e
    [1,1], #se
    [1,0], #sw
    [0,-1]] #w
  end
  #function to move one space in a direction
  def move_space(current,direction)
    output=[current.first + direction.first,current[1] + direction.last]
    output=if @board[output[0]] and @board[output[0]][output[1]] and #this checks to make sure position is valid
      not yield(@board[output[0]][output[1]]) #this checks to see if its obstructed
    then output else nil end
  end
  def all_cells
    cells=Array.new
      (0..@rows - 1).each do |x|
        (0..@cols - 1).each do |y|
          cells.push([x,y])
        end
      end
    cells 
  end
  #distance with no obstructions
  def distance(position1, position2) 
    obstructed_distance(position1, position2){|x| nil}
  end
  #arbitrarily large number we are using as infiniti for comparison purposes
  def inf
    9999
  end
  #distance with obstructions note we cant cache any of this because technically obstructions can appear for each move call
  def obstructed_distance(position1, position2, &block) 
    distance_board = Hash.new {|h,k| h[k] = Hash.new(&h.default_proc)} #not ideal but this is the magical never ending hash function 
    distances=Hash.new(inf) #the distances from positiion 1 to every other point
    unvisited=all_cells
    #runs through each cell tries to move in every direction basically figures out what paths are open between hexs
    all_cells.each do |x|
      distance_board[x][x]=0
      directions.map{|dir| move_space(x,dir){|hex| block.call(hex)}}.compact.each{|move| distance_board[x][move]=1} 
    end
    distances[position1]=0
    
    #start djkstras
    current_node=[position1.first,position1[1]]
    while unvisited.size > 0
      unvisited=unvisited.reject{|x| x==current_node}
      unvisited.reject{|x| distance_board[current_node][x].class==Hash #get rid of all the non adjacent unvisited nodes
      }.each{|x| if distances[current_node] + distance_board[current_node][x] < distances[x] then distances[x]=distances[current_node] + distance_board[current_node][x] end}  #see if any of the unvisited nodes are closer then we have so far
      current_node=unvisited.sort_by{|x| distances[x] }.first #get the new current node which is defined as the closest unvisited node
    end
    distances[position2] unless distances[position2]==inf #return nil if the distance is inf instead of 999999 or whatever inf is defined as
  end
  # This will print the board out to the console to let you 
  # know if you're on the right track 
  def draw(obstructed=nil)
    @rows.times do |row| 
      line = '' 
      line << "#{row}:" 
      (@cols - row).times {line << ' '}

      @cols.times do |col| 
        if obstructed then 
          line << (obstructed_distance([4,4], [row,col]){|x| x.obstructed?} || 'X').to_s 
        else 
          line << (distance([4,4], [row,col]) || 'X').to_s 
        end
        line << ' ' 
      end

      puts line 
    end 
  end

  def [](row) 
    @board[row] 
  end 
end

board = HexBoard.new 
board.draw
board.draw(true)

