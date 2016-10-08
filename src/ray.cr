struct Ray
  getter origin : Point
  getter direction : Vector
  getter t_min : Float64
  getter t_max : Float64

  # TODO: global epsilon constant
  def initialize(@origin, @direction, @t_min = 0.001, @t_max = Float64::MAX)
  end

  def point_at_parameter(t)
    @origin + (@direction * t)
  end
end
