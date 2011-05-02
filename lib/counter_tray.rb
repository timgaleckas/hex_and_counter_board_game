class CounterTray < Widget
  include ResourceBundle

  class CounterSelector < Widget
    def initialize(*args)
      @counter_type=args.pop
      super(*args)
    end
    def clipped_draw
      ResourceBundle.counter_tiles[@counter_type][0].draw(x,y,z+1)
    end
  end
  def initialize(x,y,z,width,height,window)
    super(x,y,z,width,height,window)
    @counter_selectors = []
    counter_x = counter_y = 0
    ResourceBundle.counter_tiles.each_with_index do |counter_tile, index|
      @counter_selectors << CounterSelector.new(x+counter_x+10,y+counter_y+10,z,COUNTER_WIDTH+10,COUNTER_HEIGHT+10,window,index)
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
    @counter_selectors.each{|cs|cs.draw}
  end
end

