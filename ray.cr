struct Ray
  getter origin, direction

  def initialize(@origin, @direction)
  end

  def point_at_parameter(t : Float)
    @origin + (@direction * t)
  end
end
