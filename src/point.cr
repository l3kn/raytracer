struct Point
  getter x, y, z

  def initialize
    @x, @y, @z = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @x, @y, @z = value, value, value
  end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  {% for op in %w(+ -) %}
    def {{op.id}}(other : Vector)
      Point.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end
  {% end %}

  def -(other : Point)
    Vector.new(@x - other.x, @y - other.y, @z - other.z)
  end

  def *(other : (Float64 | Int32))
    Point.new(@x * other, @y * other, @z * other)
  end

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  def xyz
    {@x, @y, @z}
  end
end


