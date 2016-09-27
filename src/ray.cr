struct Ray
  getter origin : Point
  getter direction : Vector

  def initialize(@origin, @direction)
  end

  def point_at_parameter(t)
    @origin + (@direction * t)
  end
end
