class InputHandler
  MOUSE_BUTTONS          = [Gosu::MsLeft,Gosu::MsMiddle,Gosu::MsRight]
  CLICK_THRESHOLD        = 100
  DOUBLE_CLICK_THRESHOLD = 300
  def initialize(window)
    @window         = window
    @input_clients  = []
    @down_events    = {}
    @click_events   = {}
  end

  def register_input_client(client,opts={})
    x = opts[:x] || client.x
    y = opts[:y] || client.y
    z = opts[:z] || client.z
    w = opts[:width]  || client.width
    h = opts[:height] || client.height
    e = opts[:event]  || :all
    @input_clients << [x,y,x+w,y+h,z,client,e]
    @input_clients = @input_clients.sort_by{|record|record[4]}
  end

  def update
    MOUSE_BUTTONS.each do |button|
      if @window.button_down?(button) && @down_events[button].nil?
        mouse_down!(button)
      elsif @down_events[button] && !@window.button_down?(button)
        mouse_up!(button)
      elsif @click_events[button] && (Gosu::milliseconds - @click_events[button]) > DOUBLE_CLICK_THRESHOLD
        mouse_click!(button)
      end
    end
  end

  private

  def mouse_down!(button)
    register_event(:mouse_down, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    @down_events[button] = Gosu::milliseconds
  end

  def mouse_up!(button)
    register_event(:mouse_up, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    if (Gosu::milliseconds - @down_events.delete(button)) < CLICK_THRESHOLD
      if @click_events[button]
        mouse_double_click!(button)
        @click_events[button] = nil
      else
        @click_events[button] = Gosu::milliseconds
      end
    end
  end

  def mouse_click!(button)
    register_event(:mouse_click, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
    @click_events[button] = nil
  end

  def mouse_double_click!(button)
    register_event(:mouse_double_click, {:button=>button,:x=>@window.mouse_x,:y=>@window.mouse_y} )
  end

  def register_event(event, opts={})
    x = opts[:x]
    y = opts[:y]
    @input_clients.each do |i|
      x1,y1,x2,y2,z,client,accepted_event = *i
      if x1 < x && x2 > x && y1 < y && y2 > y && (accepted_event==event||accepted_event==:all) && client.respond_to?(event)
        return if client.send(event,opts)
      end
    end
  end

end
