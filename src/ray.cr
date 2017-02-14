struct Ray
  getter origin : Point
  getter direction : Vector
  getter t_min : Float64
  getter t_max : Float64
  @@count = 0_u64

  def initialize(@origin, @direction, @t_min = EPSILON, @t_max = Float64::MAX)
    # puts "Non-normal direction!" if (@direction.length - 1.0).abs > EPSILON
    @@count += 1
  end

  def self.count
    @@count
  end

  def point_at_parameter(t)
    @origin + (@direction * t)
  end
end
