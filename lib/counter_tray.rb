class CounterTray < Widget
  include ResourceBundle

  class CounterSelector < Widget
    def initialize(x,y,z,width,height,window,options={})
      @counter_state=options.delete(:counter_state)
      super(x,y,z,width,height,window,{:draggable=>true}.merge(options))
    end
    def clipped_draw
      ResourceBundle.counter_tiles[@counter_state][0].draw(x,y,z+1)
    end
    def state
      @counter_state
    end
  end
  def initialize(x,y,z,width,height,window,options={})
    super
    counter_x = counter_y = 0
    ResourceBundle.counter_tiles.each_with_index do |counter_tile, index|
      add_child_view CounterSelector.new(x+counter_x+10,y+counter_y+10,z,COUNTER_WIDTH+10,COUNTER_HEIGHT+10,window,:counter_state => index)
      counter_x += 20 + COUNTER_WIDTH
      if counter_x + 20 + COUNTER_WIDTH > width
        counter_x = 0
        counter_y += 20 + COUNTER_HEIGHT
      end
    end
  end
  def clipped_draw
    b=ResourceBundle.background
    b.draw(x,y,z,width.to_f/b.width, height.to_f/b.height)
  end
  def drag_dropped(options)
    if options[:dragged_widget].class == CounterPiece
      options[:dragged_widget].hex_space.piece = nil
    end
  end

end

