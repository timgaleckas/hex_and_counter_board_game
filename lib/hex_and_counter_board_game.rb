class HexAndCounterBoardGame < Gosu::Window
  include Gosu
  def initialize(options={})
    options = {
      :tile_set => 'default'
    }.merge(options)
    super(screen_width, screen_height, false)
    caption = "Hex-and-Counter Board"
    ResourceBundle.load(self,options.delete(:tile_set))
    @input_handler = InputHandler.new(self)
    @widget = HexAndCounterBoardGameWidget.new(0,25,0,width,height-25,self,options)
    @input_handler.register_input_client(@widget)
  end
  attr_reader :input_handler
  def draw
    @widget.draw
    ResourceBundle.cursor.draw(mouse_x,mouse_y,999)
    input_handler.draw
  end
  def update
    input_handler.update
    @widget.update
  end
end
