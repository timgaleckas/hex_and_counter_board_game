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
    ResourceBundle.load(self,options.delete(:tile_set))
    @input_handler = InputHandler.new(self)
    build_menu
    @hex_board     = HexBoard.new(    0, 25, 10, @width-600, @height-25, self, options)
    @hex_palette   = HexPalette.new(  @width-600,  50,  10, 600,  375, self)
    @counter_tray  = CounterTray.new( @width-600, 425,  10, 600,  @height-425, self)
    @input_handler.register_input_client(@hex_board)
    @input_handler.register_input_client(@hex_palette)
  end

  def build_menu
    @menu          = Menu.new(        @width-600,  25,  99, 600,   25, self, :direction=>:horizontal, :display=>true)
    window = self
    tile_sets_sub_menu  = @menu.add_item('Tile Sets') do |menu|
      @menu.items.each{|i|i.undisplay_all}
      menu.display = true
    end
    ResourceBundle.available_tile_sets.each do |tile_set|
      tile_sets_sub_menu.add_item(tile_set) do
        ResourceBundle.load(window,tile_set)
      end
    end

    counter_sets_sub_menu = @menu.add_item('Counter Sets') do |menu|
      @menu.items.each{|i|i.undisplay_all}
      menu.display = true
    end
    ResourceBundle.available_counter_sets.each do |counter_set|
      counter_sets_sub_menu.add_item(counter_set) do
        puts counter_set
      end
    end
    @menu.add_item('_____') do
      @menu.items.each{|i|i.undisplay_all}
    end
    @menu.add_item('Exit') do
      window.close
    end
    @input_handler.register_input_client(@menu)
  end

  attr_reader :input_handler, :hex_palette

  def draw
    ResourceBundle.cursor.draw(self.mouse_x,self.mouse_y,999)
    @hex_board.draw
    @menu.draw
    @hex_palette.draw
    @counter_tray.draw
  end

  def update
    @input_handler.update
    @hex_board.update
    @hex_palette.update
  end

  def button_down(id)
    close if id == Gosu::KbEscape
  end
end
