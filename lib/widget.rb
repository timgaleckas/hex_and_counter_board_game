class Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,window,options={})
    options = {
      :display => true
    }.merge(options)
    @x, @y, @z, @width, @height, @window, @child_views =
     x,  y,  z,  width,  height,  window,  SortedSet.new
    @display = options.delete(:display)
    @draggable = options.delete(:draggable)
    @x_offset = options.delete(:x_offset) || 0
    @y_offset = options.delete(:y_offset) || 0
  end
  attr_reader   :x, :y, :z, :width, :height, :window, :child_views, :x_offset, :y_offset
  def draggable?; @draggable; end
  attr_accessor :display, :parent_view
  def drag_initiated(opts); @display = false; end
  def drag_ended(opts);     @display = true;  end
  def draw
    if display
      window.clip_to(x+x_offset, y+y_offset, width, height) do
        clipped_draw
        child_views.each do |child_view|
          child_view.draw
        end
      end
    end
  end
  def clipped_draw
  end
  def update
    if display
      child_views.each do |child_view|
        child_view.update
      end
    end
  end
  def clipped_draw; end
  def add_child_view(child_view)
    self.child_views << child_view
    child_view.parent_view = self
    child_view
  end
  def <=>(other)
    other.z <=> z
  end
  def method_missing(method, *args, &block)
    if parent_view
      parent_view.send(method, *args, &block)
    else
      super
    end
  end
  def x_offset=(x_o)
    @x_offset=x_o
    child_views.each{|v|v.x_offset=x_o}
  end
  def y_offset=(y_o)
    @y_offset=y_o
    child_views.each{|v|v.y_offset=y_o}
  end
end
