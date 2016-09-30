require "./helper"

struct Vector
  getter x, y, z

  X = self.new(1.0, 0.0, 0.0)
  Y = self.new(0.0, 1.0, 0.0)
  Z = self.new(0.0, 0.0, 1.0)

  ONE  = self.new(1.0)
  ZERO = self.new(0.0)

  def initialize
    @x, @y, @z = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @x, @y, @z = value, value, value
  end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  # `/` is only used in aabb.cr:11 
  {% for op in %w(+ - /) %}
    def {{op.id}}(other : Vector)
      Vector.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end
  {% end %}

  def *(other : (Float | Int))
    Vector.new(@x * other, @y * other, @z * other)
  end

  def /(other : (Float | Int))
    inv = 1.0 / other
    Vector.new(@x * inv, @y * inv, @z * inv)
  end

  def dot(other)
    @x * other.x + @y * other.y + @z * other.z
  end

  def cross(other)
    Vector.new(
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
    inv = 1.0 / length
    self * inv
  end

  def to_normal
    inv = 1.0 / length
    Normal.new(self.x * inv, self.y * inv, self.z * inv)
  end

  # Swizzling
  {% for first in %w(x y z) %}
    {% for second in %w(x y z) %}
      def {{first.id}}{{second.id}}
        { @{{first.id}}, @{{second.id}} }
      end
    {% end %}
  {% end %}

  def -
    Vector.new(-@x, -@y, -@z)
  end

  # TODO: move this to the normal class
  # and flip the arguments `normal.reflect(vector)
  def reflect(normal)
    dt = self.dot(normal)

    Vector.new(
      self.x - normal.x * dt * 2.0,
      self.y - normal.y * dt * 2.0,
      self.z - normal.z * dt * 2.0,
    )
    # self - normal*dot(normal)*2.0
  end

  # TODO: move this to the normal class
  def refract(normal, eta)
    dt = normalize.dot(normal)
    discriminant = 1.0 - (eta**2) * (1 - dt**2)

    if discriminant > 0
      normalize * eta - normal * (eta * dt + Math.sqrt(discriminant))
    else
      nil
    end
  end

  # TODO, see Normal.to_normal
  def to_vector
    self
  end

  def xyz
    {@x, @y, @z}
  end

  def max(other : Float64)
    Vector.new(
      max(@x, other),
      max(@y, other),
      max(@z, other)
    )
  end
end
