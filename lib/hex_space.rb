class HexSpace < Widget
  class<<self
    attr_accessor :initial_hex_state
    attr_accessor :current_rolling_value
  end
  attr_reader :board
  attr_writer :state
  attr_accessor :piece

  def initialize(x,y,z,width,height,window,options={})
    @board = options.delete(:board)
    @state = options.delete(:specified_initial_state) || initial_state
    super
  end

  def initial_state
    return self.class.initial_hex_state == :rolling ?
      self.class.current_rolling_value = ((self.class.current_rolling_value || -1) + 1) :
      self.class.initial_hex_state
  end

  def draw(x_offset,y_offset)
    ResourceBundle.hex_tiles[state].draw(x_offset+x,y_offset+y,z)
    self.piece.draw if self.piece
  end

  def state
    @state % ResourceBundle.hex_tiles.size
  end

  def drag_dropped(options)
    if options[:dragged_widget].class == HexPalette::Selector
      @state = options[:dragged_widget].state
    end
  end
end
