require "./helper"

struct Vec3
  getter x, y, z

  def initialize
    @x, @y, @z = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @x, @y, @z = value, value, value
  end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  def xyz
    {@x, @y, @z}
  end

  {% for op in %w(+ - * /) %}
    def {{op.id}}(other : Vec3)
      Vec3.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end

    def {{op.id}}(other : Float)
      Vec3.new(@x {{op.id}} other, @y {{op.id}} other, @z {{op.id}} other)
    end

    def {{op.id}}(other : Int)
      Vec3.new(@x {{op.id}} other, @y {{op.id}} other, @z {{op.id}} other)
    end
  {% end %}

  def -
    Vec3.new(-@x, -@y, -@z)
  end

  def abs
    Vec3.new(@x.abs, @y.abs, @z.abs)
  end

  def max(n)
    Vec3.new(max(n, @x), max(n, @y), max(n, @z))
  end

  def dot(other)
    @x * other.x + @y * other.y + @z * other.z
  end

  def cross(other)
    Vec3.new(
      @y * other.z - @z * other.y,
      @z * other.x - @x * other.z,
      @x * other.y - @y * other.x
    )
  end

  def squared_length
    dot(self)
  end

  def length
    Math.sqrt(squared_length)
  end

  def normalize
    l = length
    Vec3.new(@x / l, @y / l, @z / l)
  end

  def reflect(normal)
    self - normal*dot(normal)*2.0
  end

  def refract(normal, eta)
    dt = normalize.dot(normal)
    discriminant = 1.0 - (eta**2) * (1-dt**2)

    if discriminant > 0
      normalize * eta - normal * (eta * dt + Math.sqrt(discriminant))
    else
      nil
    end
  end
end
