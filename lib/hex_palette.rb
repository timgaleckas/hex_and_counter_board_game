class HexPalette < Widget
  class Selector < Widget
    def initialize(x,y,z,width,height,window,options={})
      @state, @palette, @selected = 
        options.delete(:state),
        options.delete(:palette),
        !!options.delete(:selected)
      super
    end
    attr_accessor :selected
    attr_reader   :palette, :state
    def clipped_draw
      ResourceBundle.hex_tiles[state].draw(x,y,z)
      @selected ? ResourceBundle.hex_check_box.draw(x,y,z+1) :
                  ResourceBundle.hex_uncheck_box.draw(x,y,z+1)
    end
    def mouse_down(opts)
      palette.clear_selection
      @selected = true
      true
    end
  end
  def clipped_draw
    b=ResourceBundle.background
    b.draw(x,y,z,width.to_f/b.width, height.to_f/b.height)
    hex_selectors.each{|selector|selector.draw}
  end
  def update
    @hex_selectors = nil if hex_selectors && hex_selectors.size != ResourceBundle.hex_tiles.size
  end
  def clear_selection; hex_selectors.each  {|hs|hs.selected = false}; end
  def state_selected;  hex_selectors.detect{|hs|hs.selected};         end
  def hex_selectors
    return @hex_selectors if @hex_selectors
    number_of_hexes_per_row = (width / (HEX_WIDTH + 20)).floor
    xs = (1..number_of_hexes_per_row-1).map{|n| (((n.to_f/number_of_hexes_per_row)*width)-(HEX_WIDTH/2)).floor}
    xs = xs.map{|an_x|an_x+x}
    @window.input_handler.deregister_clients(*@hex_selectors) if @hex_selectors
    @hex_selectors = []
    palette = self
    current_y = y+20
    x_index   = 0
    ResourceBundle.hex_tiles.each_with_index do |hex_tile, index|
      if x_index >= xs.size
        x_index = 0
        current_y += 20+HEX_HEIGHT
      end
      current_x      =  xs[x_index]
      selector       =  Selector.new(    current_x,current_y,z+2,HEX_WIDTH,HEX_HEIGHT, window, :palette=>self, :state=>index)
      window.input_handler.register_input_client(selector)
      @hex_selectors << selector
      x_index += 1
    end
    @hex_selectors
  end
end
