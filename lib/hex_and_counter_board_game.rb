class HexAndCounterBoardGame < Gosu::Window
  def initialize(options={})
    options = {
      :tile_set          => "default",
      :columns           => 15,
      :rows              => 22,
      :initial_hex_state => 0
    }.merge(options)
    @width, @height = Gosu.screen_width, Gosu.screen_height
    super(@width, @height, true)
    self.caption = "Hex-and-Counter Board"
    ResourceBundle.load(self,options.delete(:tile_set))
    @input_handler = InputHandler.new(self)
    @hex_board     = HexBoard.new(    0, 25, 10, @width-600, @height-25, self, options)
    @menu          = Menu.new(        @width-600,  25,  99, 600,   25, self)
    @close_button  = CloseButton.new( @width -25,  25,  10,  25,   25, self)
    @hex_palette   = HexPalette.new(  @width-600,  50,  10, 600,  375, self, :options=>menu_options)
    @counter_tray  = CounterTray.new( @width-600, 425,  10, 600,  @height-425, self)
    @input_handler.register_input_client(@close_button)
    @input_handler.register_input_client(@hex_board)
    @input_handler.register_input_client(@hex_palette)
  end

  def menu_options
    { :tile_sets => ['default'], :piece_sets => ['default'],
      :exit => nil }
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

  def button_down(id)
    exit if id == Gosu::KbEscape
  end
end
