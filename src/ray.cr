struct Ray
  getter origin : Vec3
  getter direction : Vec3

  def initialize(@origin, @direction)
  end

  def point_at_parameter(t)
    @origin + (@direction * t)
  end
end
