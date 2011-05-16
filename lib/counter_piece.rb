class CounterPiece < Widget
  def initialize(x,y,z,width,height,window,options={})
    @state = options.delete(:state) || 0
    super(x,y,z,width,height,window,{:draggable=>true}.merge(options))
    @side  = 0
  end
  attr_reader :state, :side
  def clipped_draw
    ResourceBundle.counter_tiles[state][side].draw(x,y,z)
  end

  def mouse_click(*a)
    @side = @side==0 ? 1 : 0
  end
end
