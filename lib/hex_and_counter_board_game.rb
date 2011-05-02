class HexAndCounterBoardGame < Gosu::Window
  def initialize(options={})
    options = {
      :tile_set          => "default",
      :columns           => 15,
      :rows              => 22,
      :initial_hex_state => 0
    }.merge(options)
    @width, @height = Gosu.screen_width, Gosu.screen_height
    super(@width, @height, false)
    self.caption = "Hex-and-Counter Board"
    ResourceBundle.load(self,options[:tile_set])
    @input_handler = InputHandler.new(self)
    @hex_board     = HexBoard.new(    0, 0, 10, @width-600, @height, options[:columns], options[:rows], self, options[:initial_hex_state])
    @close_button  = CloseButton.new( @width-50,    0,  10,  50,   50, self)
    @hex_palette   = HexPalette.new(  @width-600,  50,  10, 600,  300, self)
    @counter_tray  = CounterTray.new( @width-600, 350,  10, 600,  650, self)
    @input_handler.register_input_client(@hex_board)
    @input_handler.register_input_client(@hex_palette)
  end

  attr_reader :input_handler, :hex_palette

  def draw
    ResourceBundle.cursor.draw(self.mouse_x,self.mouse_y,999)
    @hex_board.draw
    @close_button.draw
    @hex_palette.draw
    @counter_tray.draw
  end

  def update
    @input_handler.update
    @hex_board.update
    @hex_palette.update
  end
end
