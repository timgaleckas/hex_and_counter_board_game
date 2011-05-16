class Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,window,options={})
    options = {
      :display => true
    }.merge(options)
    @x, @y, @z, @width, @height, @window, @child_views,   @display,                  @draggable =
     x,  y,  z,  width,  height,  window,  SortedSet.new,  options.delete(:display),  options.delete(:draggable)
  end
  attr_reader   :x, :y, :z, :width, :height, :window, :child_views
  def draggable?; @draggable; end
  attr_accessor :display, :parent_view
  def drag_initiated(opts); @display = false; end
  def drag_ended(opts);     @display = true;  end
  def draw
    if display
      window.clip_to(x, y, width, height) do
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
end
