struct Ray
  getter origin : Point
  getter direction : Vector
  getter t_min : Float64, t_max : Float64
  @@count = 0_u64

  getter inv_direction : Vector
  getter sign : Tuple(Int32, Int32, Int32)

  def initialize(@origin, @direction, @t_min = EPSILON, @t_max = Float64::MAX)
    @@count += 1
    @inv_direction = Vector.new(
      1.0 / @direction.x,
      1.0 / @direction.y,
      1.0 / @direction.z,
    )

    @sign = {
      @inv_direction.x < 0 ? 1 : 0,
      @inv_direction.y < 0 ? 1 : 0,
      @inv_direction.z < 0 ? 1 : 0,
    }
  end

  def self.count
    @@count
  end

  def point_at_parameter(t)
    @origin + (@direction * t)
  end
end
