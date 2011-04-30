class HexPalette < Widget
  class Selector < Widget
    def initialize(*args)
      @palette = args.pop
      super(*args)
    end
    attr_accessor :selected
    def clipped_draw
      @selected ? ResourceBundle.hex_check_box.draw(x,y,z) :
                  ResourceBundle.hex_uncheck_box.draw(x,y,z)
    end
    def mouse_click(opts)
      @palette.click_selector(self)
      true
    end
  end
  attr_reader :hexes
  def clipped_draw
    b=ResourceBundle.background
    b.draw(@x,@y,@z,@width.to_f/b.width, @height.to_f/b.height)
    hexes.each{|hex|hex.draw(@x,@y)}
    @hex_selectors.each{|selector|selector.draw}
  end
  def update
    @hexes = nil if hexes.size != ResourceBundle.hex_tiles.size
  end
  def click_selector(selector)
    @hex_selectors.each{|s|s==selector ? s.selected = !s.selected : s.selected = nil }
  end
  def state_selected
    @hex_selectors.each_with_index{|s,index|return @hexes[index].state if s.selected}
    nil
  end
  def hexes
    return @hexes if @hexes
    number_of_hexes_per_row = (@width / (ResourceBundle::HEX_WIDTH + 20)).floor
    xs = (1..number_of_hexes_per_row-1).map{|n| (((n.to_f/number_of_hexes_per_row)*@width)-(ResourceBundle::HEX_WIDTH/2)).floor}
    number_of_rows = (ResourceBundle.hex_tiles.size / number_of_hexes_per_row) + 1
    ys = (0..number_of_rows-1).map{|n| 20+(n*(ResourceBundle::HEX_HEIGHT+20)) }
    @hexes = []
    @window.input_handler.deregister_clients(*@hex_selectors) if @hex_selectors
    @hex_selectors = []
    palette = self
    ys.each_with_index do |y,yi|
      xs.each_with_index do |x,xi|
        state = yi*xs.size+xi
        if state < ResourceBundle.hex_tiles.size
          @hexes         << HexSpace.new(nil,x,y,z+1,yi*xs.size+xi) 
          selector = Selector.new(    palette.x+x,palette.y+y,z+2,ResourceBundle::HEX_WIDTH,ResourceBundle::HEX_HEIGHT, @window, self)
          @window.input_handler.register_input_client(selector)
          @hex_selectors << selector
        end
      end
    end
    @hexes
  end
  def mouse_click(opts={})
    ResourceBundle.tile_set = 'tile_set_1'
    true
  end
  def mouse_double_click(opts={})
    ResourceBundle.tile_set = 'default'
    true
  end
end
