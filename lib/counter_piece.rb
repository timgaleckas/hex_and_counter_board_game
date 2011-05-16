class CounterPiece < Widget
  WIDTH = ResourceBundle.counter_tiles.first.first.width
  HEIGHT = ResourceBundle.counter_tiles.first.first.height
  def initialize(x,y,z,width,height,window,options={})
    @state = options.delete(:state) || 0
    super(x,y,z,width,height,window,{:draggable=>true}.merge(options))
    @side  = 0
  end
  attr_reader :state, :side
  attr_accessor :hex_space
  def clipped_draw
    ResourceBundle.counter_tiles[state][side].draw(x+x_offset,y+y_offset,z)
  end

  def mouse_click(*a)
    @side = @side==0 ? 1 : 0
    true
  end
  def mouse_down(*a)
    true
  end
end
