require 'gosu'

module ZOrder
  BACKGROUND, MIDDLE, TOP = *0..2
end

MAP_WIDTH = 200
MAP_HEIGHT = 200
CELL_DIM = 20

class Cell
  # have a pointer to the neighbouring cells
  attr_accessor :north, :south, :east, :west, :vacant, :visited, :on_path

  def initialize()
    # Set the pointers to nil
    @north = nil
    @south = nil
    @east = nil
    @west = nil
    # record whether this cell is vacant
    # default is not vacant i.e is a wall.
    @vacant = false # to track whether the cell is passable (true) or a wall (false)
    # this stops cycles - set when you travel through a cell
    @visited = false # to avoid revisiting the same cell
    @on_path = false
  end
end

# Instructions:
# Left click on cells to create a maze with at least one path moving from
# left to right.  The right click on a cell for the program to find a path
# through the maze. When a path is found it will be displayed in red.
class GameWindow < Gosu::Window

  # initialize creates a window with a width an a height
  # and a caption. It also sets up any variables to be used.
  # This is procedure i.e the return value is 'undefined'
  def initialize
    super MAP_WIDTH, MAP_HEIGHT, false # window size 200 x 200
    self.caption = "Map Creation"
    @path = nil

    x_cell_count = MAP_WIDTH / CELL_DIM # 200/20 = 10
    y_cell_count = MAP_HEIGHT / CELL_DIM # 200/20 = 10

    @columns = Array.new(x_cell_count) # array representing columns
    column_index = 0

    # first create cells for each position
    while (column_index < x_cell_count) # outer loop for column
      row = Array.new(y_cell_count)
      @columns[column_index] = row # store the row array into the columns array
      row_index = 0
      while (row_index < y_cell_count) # inner loop for rows
        cell = Cell.new()
        @columns[column_index][row_index] = cell #####
        row_index += 1
      end
      column_index += 1
    end

    # now set up the neighbour links
    # You need to do this using a while loop with another
    # nested while loop inside.
    column_index = 0 # neighbour links loops
    while (column_index < x_cell_count) # outer loop for columns
      row_index = 0
      while (row_index < y_cell_count) # inner loop for rows
        if (column_index < x_cell_count - 1 && column_index > -1) # if there's a cell to the east
          @columns[column_index][row_index].east = @columns[column_index + 1][row_index] # yes, set east to the next column of the same row
        else
          @columns[column_index][row_index].east = nil
        end
        if (row_index > 0 && row_index < y_cell_count) # if there's a cell to the north 
          @columns[column_index][row_index].north = @columns[column_index][row_index -1] # yes, set north to previous row in same column
        else 
          @columns[column_index][row_index].north  = nil
        end
        row_index += 1
      end
      column_index += 1
    end
  end

  # implement print_cell function
  def print_cell
    i = 0
    while (i <= MAP_WIDTH / CELL_DIM)
      j = 1
      while j <= MAP_HEIGHT / CELL_DIM

        cell = @columns[j-1][i-1]

        north = cell.north.nil? ? "0" : "1"
        south = cell.south.nil? ? "0" : "1"
        east = cell.east.nil?  ? "0" : "1"
        west = cell.west.nil?  ? "0" : "1"

        puts "Cell x: #{i-1}, y: #{j-1} north:#{north} south:#{south} east:#{east} west:#{west}"

        j += 1
      end

      puts "-------- End of column --------"
      i += 1
    end
  end

  # this is called by Gosu to see if should show the cursor (or mouse)
  def needs_cursor?
    true
  end

  # Returns an array of the cell x and y coordinates that were clicked on
  def mouse_over_cell(mouse_x, mouse_y)
    if mouse_x <= CELL_DIM
      cell_x = 0 # map to column 0
    else
      cell_x = (mouse_x / CELL_DIM).to_i
    end

    if mouse_y <= CELL_DIM
      cell_y = 0 # map to row 0
    else
      cell_y = (mouse_y / CELL_DIM).to_i
    end

    [cell_x, cell_y] # return an array [x,y] of the cell coordinates
  end

  # start a recursive search for paths from the selected cell
  # it searches till it hits the East 'wall' then stops
  # it does not necessarily find the shortest path

  # Completing this function is NOT NECESSARY for the Maze Creation task
  # complete the following for the Maze Search task - after
  # we cover Recusion in the lectures.

  # But you DO need to complete it later for the Maze Search task
  def search(cell_x ,cell_y)
  cell = @columns[cell_x][cell_y]

  # skip if cell is invalid, not vacant, or already visited
  return nil if cell.nil? || !cell.vacant || cell.visited

  cell.visited = true

  # base case: reached east wall
  if (cell_x == ((MAP_WIDTH / CELL_DIM) - 1))
    puts "End of one path x: #{cell_x} y: #{cell_y}" if ARGV.length > 0
    return [[cell_x,cell_y]]
  end

  north_path = nil
  south_path = nil
  east_path  = nil
  west_path  = nil

  puts "Searching. In cell x: #{cell_x} y: #{cell_y}" if ARGV.length > 0

  # check north
  if cell.north && cell.north.vacant && !cell.north.visited
    north_path = search(cell_x, cell_y - 1)
  end

  # check south
  if cell.south && cell.south.vacant && !cell.south.visited
    south_path = search(cell_x, cell_y + 1)
  end

  # check east
  if cell.east && cell.east.vacant && !cell.east.visited
    east_path = search(cell_x + 1, cell_y)
  end

  # check west
  if cell.west && cell.west.vacant && !cell.west.visited
    west_path = search(cell_x - 1, cell_y)
  end

  # pick one of the possible paths
  path = nil
  if north_path != nil
    path = north_path
  elsif south_path != nil
    path = south_path
  elsif east_path != nil
    path = east_path
  elsif west_path != nil
    path = west_path
  end

  if path != nil
    puts "Added x: #{cell_x} y: #{cell_y}" if ARGV.length > 0
    [[cell_x,cell_y]].concat(path)
  else
    puts "Dead end x: #{cell_x} y: #{cell_y}" if ARGV.length > 0
    nil
  end
end


  # Reacts to button press
  # left button marks a cell vacant
  # Right button starts a path search from the clicked cell
  def button_down(id) # id is a constant from GOSU
    case id # start a case id on the button id
      when Gosu::MsLeft # when left mouse button is pressed
        cell = mouse_over_cell(mouse_x, mouse_y)
        if (ARGV.length > 0) # debug
          puts("Cell clicked on is x: " + cell[0].to_s + " y: " + cell[1].to_s)
        end
        @columns[cell[0]][cell[1]].vacant = true
      when Gosu::MsRight # if right mouse is pressed 
        cell = mouse_over_cell(mouse_x, mouse_y) # compute the clicked cell 
        @path = search(cell[0],cell[1]) # call search 
      end
  end

  # This will walk along the path setting the on_path for each cell
  # to true. Then draw checks this and displays them a red colour.
  def walk(path)
      index = path.length
      count = 0
      while (count < index) # loop thru each coordinate in the path
        cell = path[count] # take the coordinate pair [x,y] at position count
        @columns[cell[0]][cell[1]].on_path = true
        count += 1
      end
  end

  # Put any work you want done in update
  # This is a procedure i.e the return value is 'undefined'
  def update
    if (@path != nil) 
      if (ARGV.length > 0) # debug
        puts "Displaying path"
        puts @path.to_s
      end
      walk(@path)
      @path = nil
    end
  end

  # Draw (or Redraw) the window
  # This is procedure i.e the return value is 'undefined'
  def draw
    index = 0
    x_loc = 0;
    y_loc = 0;

    x_cell_count = MAP_WIDTH / CELL_DIM
    y_cell_count = MAP_HEIGHT / CELL_DIM

    column_index = 0
    while (column_index < x_cell_count) # outer loop over columns
      row_index = 0
      while (row_index < y_cell_count) # inner loop over rows

        if (@columns[column_index][row_index].vacant) # if cell is marked as VACANT(OPEN)
          color = Gosu::Color::YELLOW # base color = yellow
        else
          color = Gosu::Color::GREEN # wall = green
        end
        if (@columns[column_index][row_index].on_path) # if cell has been marked as discovered path
          color = Gosu::Color::RED # override with red color
        end

        Gosu.draw_rect(column_index * CELL_DIM, row_index * CELL_DIM, CELL_DIM, CELL_DIM, color, ZOrder::TOP, mode=:default)

        row_index += 1
      end
      column_index += 1
    end
  end
end

window = GameWindow.new
window.print_cell 
window.show