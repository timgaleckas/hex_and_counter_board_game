class Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,window,options={})
    @x, @y, @z, @width, @height, @window =
     x,  y,  z,  width,  height,  window
  end
  attr_reader :x, :y, :z, :width, :height, :window
  def draw
    @window.clip_to(@x, @y, @width, @height) do
      clipped_draw
    end
  end
end
