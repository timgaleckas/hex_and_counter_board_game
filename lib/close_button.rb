class CloseButton < Widget
  include Gosu
  def clipped_draw
    Image.from_text(window,'X','Verdana',22).draw(x,y,99,1,1)
  end
  def mouse_click(options)
    exit
  end
end
