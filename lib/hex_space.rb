class HexSpace
  def initialize(board, x, y, z, initial_state)
    @board, @x, @y, @z, @state = 
     board,  x,  y,  z,  initial_state
  end
  attr_reader :board, :state, :x, :y, :z
  def draw(x_offset,y_offset)
    ResourceBundle.hex_tiles[state].draw(x_offset+x,y_offset+y,z)
  end
  def register_click
    @state += 1
    @state = @state % ResourceBundle.hex_tiles.size
  end
end
