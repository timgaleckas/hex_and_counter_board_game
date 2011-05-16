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
    @x_offset = options.delete(:x_offset)
    @y_offset = options.delete(:y_offset)
    initial_child_views = options.delete(:child_views) || []
    initial_child_views.each{|v|add_child_view v}
  end
  attr_writer   :x_offset, :y_offset
  attr_reader   :x, :y, :z, :width, :height, :window, :child_views
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
  def x_offset; @x_offset || (parent_view ? parent_view.x_offset : 0); end
  def y_offset; @y_offset || (parent_view ? parent_view.y_offset : 0); end
  def grow
    @height = ([height]+child_views.map{|v|v.grow;v.y+v.height-y}).max
    @width  = ([width] +child_views.map{|v|v.grow;v.x+v.width-x}).max
  end
end
