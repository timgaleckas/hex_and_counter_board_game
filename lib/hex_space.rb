class HexSpace < Widget
  class<<self
    attr_accessor :initial_hex_state
    attr_accessor :current_rolling_value
  end
  attr_reader :board, :piece
  attr_writer :state

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

  def clipped_draw
    ResourceBundle.hex_tiles[state].draw(x_offset+x,y_offset+y,z)
  end

  def state
    @state % ResourceBundle.hex_tiles.size
  end

  def drag_dropped(options)
    if options[:dragged_widget].class == HexPalette::Selector
      @state = options[:dragged_widget].state
    elsif options[:dragged_widget].class == CounterTray::CounterSelector
      self.piece = CounterPiece.new(x+(width/2)-(CounterPiece::WIDTH/2),y+(height/2)-(CounterPiece::HEIGHT/2),z+99,CounterPiece::WIDTH,CounterPiece::HEIGHT,window,:state=>options[:dragged_widget].state)
    elsif options[:dragged_widget].class == CounterPiece
      self.piece = options[:dragged_widget]
    end
  end

  def child_views
    [piece].compact
  end

  def piece=(p)
    if p
      p.instance_variable_set('@x', x+(width/2)-(CounterPiece::WIDTH/2))
      p.instance_variable_set('@y', y+(height/2)-(CounterPiece::HEIGHT/2))
      p.hex_space.piece=nil if p.hex_space
      p.hex_space = self
    end
    @piece = p
  end

  def r(p); ChunkyPNG::Color.r(p); end
  def g(p); ChunkyPNG::Color.g(p); end
  def b(p); ChunkyPNG::Color.b(p); end

  def mouse_down(options)
    x_in_tile = options[:x] - x - x_offset
    y_in_tile = options[:y] - y - y_offset
    pixel = ResourceBundle.mask.get_pixel(x_in_tile,y_in_tile)
    return false if r(pixel) > 0 || g(pixel) > 0 || b(pixel) > 0
    self.state = parent_view.parent_view.hex_palette.state_selected.state if parent_view.parent_view.hex_palette.state_selected
    return true
  end
end
