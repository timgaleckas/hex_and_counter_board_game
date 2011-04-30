class HexSpace
  def initialize(board, x, y, z, initial_state)
    @board, @x, @y, @z, @state = 
     board,  x,  y,  z,  initial_state
  end
  attr_reader :board, :x, :y, :z
  def draw(x_offset,y_offset)
    ResourceBundle.hex_tiles[state].draw(x_offset+x,y_offset+y,z)
  end
  def register_click
    self.state += 1
  end
  def state
    @state % ResourceBundle.hex_tiles.size
  end
  attr_writer :state
end
