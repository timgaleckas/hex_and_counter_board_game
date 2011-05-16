class InputHandler
  MOUSE_BUTTONS          = [Gosu::MsLeft,Gosu::MsMiddle,Gosu::MsRight]
  def initialize(window)
    @window         = window
    @input_clients  = SortedSet.new
    @down_events    = {}
    @click_events   = {}
    @drag_events    = {}
    @mouse_over     = []
  end

  class InputClientRecord
    def initialize(x1,y1,x2,y2,z,client,e)
      @x1, @y1, @x2, @y2, @z, @client, @e =
       x1,  y1,  x2,  y2,  z,  client,  e
    end
    attr_reader :x1, :y1, :x2, :y2, :z, :client, :e
    def <=>(other)
      other.z <=> self.z
    end
  end

  def register_input_client(client,opts={})
    x = opts[:x] || client.x
    y = opts[:y] || client.y
    z = opts[:z] || client.z
    w = opts[:width]  || client.width
    h = opts[:height] || client.height
    e = opts[:event]  || :all
    @input_clients << InputClientRecord.new(x,y,x+w,y+h,z,client,e)
  end

  def deregister_clients(*clients)
    @input_clients.reject!{|record| clients.include?(record.client) }
  end

  def draw
    if @drag_ghost
      @drag_ghost[:widget].instance_variable_set('@x', mouse_event.x - @drag_ghost[:x_offset])
      @drag_ghost[:widget].instance_variable_set('@y', mouse_event.y - @drag_ghost[:y_offset])
      @drag_ghost[:widget].draw
    end
  end

  def update
    @mouse_event = MouseEvent.new(@window)
    mouse_currently_over = SortedSet.new
    @input_clients.each do |v|
      find_currently_over_from_client(v.client,mouse_currently_over,@mouse_event.x,@mouse_event.y)
    end
    mouse_currently_over = mouse_currently_over.map{|e|e.client}
    mouse_exited  = @mouse_over - mouse_currently_over
    mouse_entered = mouse_currently_over - @mouse_over
    @mouse_over   = mouse_currently_over

    mouse_exited.each{  |client| mouse_exited!(client)  }
    mouse_entered.each{ |client| mouse_entered!(client) }

    MOUSE_BUTTONS.each do |button|
      if @window.button_down?(button) && @down_events[button].nil?
        mouse_down!(button)
      elsif @down_events[button] && !@window.button_down?(button)
        mouse_up!(button)
      elsif @down_events[button] && @window.button_down?(button)
        #button was down and still is. check for drag
        drag_initiated!(button, @down_events[button]) if !@drag_events[button] && !@mouse_event.within_drag_threshold_of(@down_events[button])
      elsif @click_events[button] && !@mouse_event.within_double_click_threshold_of(@click_events[button])
        mouse_click!(button, @click_events[button])
      end
      drag_ended!(button) if @drag_events[button] && !@down_events[button]
    end
  end

  private
  class MouseEvent
    include Gosu

    CLICK_TIME_THRESHOLD        = 121
    DOUBLE_CLICK_TIME_THRESHOLD = 201

    def initialize(window)
      @milliseconds = Gosu::milliseconds
      @x            = window.mouse_x.floor
      @y            = window.mouse_y.floor
    end

    attr_reader   :milliseconds, :x, :y
    attr_accessor :dragged_widget

    def within_drag_threshold_of(mouse_event)
      distance(self.x,self.y,mouse_event.x,mouse_event.y) <= 20
    end
    def within_click_threshold_of(mouse_event)
      (self.milliseconds-mouse_event.milliseconds).abs <= CLICK_TIME_THRESHOLD &&
        self.within_drag_threshold_of(mouse_event)
    end
    def within_double_click_threshold_of(mouse_event)
      (self.milliseconds-mouse_event.milliseconds).abs <= DOUBLE_CLICK_TIME_THRESHOLD &&
        self.within_drag_threshold_of(mouse_event)
    end
  end

  attr_reader :mouse_event

  def mouse_down!(button)
    register_event(:mouse_down, {:button=>button,:x=>mouse_event.x,:y=>mouse_event.y} )
    @down_events[button] = mouse_event
  end

  def drag_initiated!(button, down_event)
    dragged_widget = start_drag(:button=>button,:x=>down_event.x,:y=>down_event.y)
    if dragged_widget
      drag_event = down_event.dup
      drag_event.dragged_widget = dragged_widget
      @drag_events[button] = drag_event
    end
  end

  def start_drag(opts={})
    x = opts[:x]
    y = opts[:y]
    possible_targets_at(x,y).each do |i|
      if i.client.draggable?
        @drag_ghost = {
          :widget   => i.client.dup,
          :x_offset => opts[:x] - i.client.x,
          :y_offset => opts[:y] - i.client.y
        }
        i.client.send(:drag_initiated,opts)
        return i.client
      end
    end
    nil
  end

  def drag_ended!(button)
    drag_event = @drag_events[button]
    drag_event.dragged_widget.send(:drag_ended,{})
    register_event(:drag_dropped, {:button=>button,:x=>mouse_event.x,:y=>mouse_event.y,:dragged_widget=>drag_event.dragged_widget} )
    @drag_events[button] = nil
    @drag_ghost = nil
  end

  def mouse_up!(button)
    register_event(:mouse_up, {:button=>button,:x=>mouse_event.x,:y=>mouse_event.y} )
    down_event = @down_events.delete(button)
    if MouseEvent.new(@window).within_click_threshold_of(down_event)
      if @click_events[button]
        mouse_double_click!(button, down_event)
        @click_events[button] = nil
      else
        @click_events[button] = down_event
      end
    end
  end

  def mouse_click!(button, down_event)
    register_event(:mouse_click, {:button=>button,:x=>down_event.x,:y=>down_event.y} )
    @click_events[button] = nil
  end

  def mouse_double_click!(button, down_event)
    register_event(:mouse_double_click, {:button=>button,:x=>down_event.x,:y=>down_event.y} )
  end

  def mouse_entered!(client)
    client.send(:mouse_entered,{}) if client.respond_to?(:mouse_entered)
  end

  def mouse_exited!(client)
    client.send(:mouse_exited,{}) if client.respond_to?(:mouse_exited)
  end

  def register_event(event, opts={})
    x = opts[:x]
    y = opts[:y]
    possible_targets_at(x,y).each do |i|
      x1,y1,x2,y2,z,client,accepted_event = i.x1, i.y1, i.x2, i.y2, i.z, i.client, i.e
      if x1 < x && x2 > x && y1 < y && y2 > y && (accepted_event==event||accepted_event==:all) && client.respond_to?(event)
        return if client.send(event,opts)
      end
    end
    nil
  end

  private

  def possible_targets_at(x,y)
    targets = SortedSet.new
    @input_clients.each do |v|
      find_currently_over_from_client(v.client,targets,x,y)
    end
    targets
  end

  def find_currently_over_from_client(client,set_to_fill,x,y)
    c = client
    if c.display
      x1, y1, x2, y2 = c.x,c.y,c.x+c.width,c.y+c.height
      if x1 < x && x2 > x && y1 < y && y2 > y
        set_to_fill << InputClientRecord.new(c.x,c.y,c.x+c.width,c.y+c.height,c.z,c,:all)
        c.child_views.each{|child_view|find_currently_over_from_client(child_view,set_to_fill,x,y)}
      end
    end
  end

end
