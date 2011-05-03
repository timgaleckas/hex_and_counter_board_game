class CloseButton < Widget
  include Gosu
  def clipped_draw
    image.draw(x,y,99,width.to_f/image.width,height.to_f/image.height)
  end
  def image
    @image ||= Image.from_text(window,'X','Verdana',200)
  end
  def mouse_click(options)
    window.close
  end
end
