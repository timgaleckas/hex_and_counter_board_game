class HexSpace
  class<<self
    attr_accessor :initial_hex_state
  end
  attr_reader :board, :x, :y, :z

  def initialize(board, x, y, z, specified_initial_state = nil)
    @board, @x, @y, @z = 
     board,  x,  y,  z
    @state = specified_initial_state || initial_state
  end

  def initial_state
    return self.class.initial_hex_state
    # (self.class.initial_hex_state == :rolling) ?
    #   row*@columns+column :
    #   @initial_hex_state
  end

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
