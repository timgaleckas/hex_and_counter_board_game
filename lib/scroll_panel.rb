class ScrollPanel < Widget
  def initialize(x,y,z,width,height,window,options={})
    super
    center
    update_child_view_offsets
  end

  def center
    @x_scroll_offset = -1 * x_overflow/2
    @y_scroll_offset = -1 * y_overflow/2
  end

  def update
    return if @window.mouse_y < y   ||
      @window.mouse_x < x           ||
      @window.mouse_y > y + height ||
      @window.mouse_x > x + width
    border_width = 75
    scroll_left!  if @window.mouse_x > x + width - border_width
    scroll_right! if @window.mouse_x < x + border_width
    scroll_down!  if @window.mouse_y < y + border_width
    scroll_up!    if @window.mouse_y > y + height - border_width
    update_child_view_offsets
  end

  def clipped_draw
    b=ResourceBundle.background
    b.draw(x+x_offset,y+y_offset,z,width.to_f/b.width, height.to_f/b.height)
  end

  def update_child_view_offsets
    child_views.each do |view|
      view.x_offset=@x_scroll_offset
      view.y_offset=@y_scroll_offset
    end
  end

  private
  def scroll_up!;    @y_scroll_offset -= [10,(@y_scroll_offset+y_overflow).abs].min if y_overflow > 0; end
  def scroll_down!;  @y_scroll_offset += [10,@y_scroll_offset.abs].min              if y_overflow > 0; end
  def scroll_left!;  @x_scroll_offset -= [10,(@x_scroll_offset+x_overflow).abs].min if x_overflow > 0; end
  def scroll_right!; @x_scroll_offset += [10,@x_scroll_offset.abs].min              if x_overflow > 0; end

  def max_child_view_height; (child_views.to_a.map{|v|(v.y+v.height)-y}).max; end
  def max_child_view_width;  (child_views.to_a.map{|v|(v.x+v.width )-x}).max; end
  def x_overflow;            max_child_view_width  - width;        end
  def y_overflow;            max_child_view_height - height;       end

end
