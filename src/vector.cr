require "./helper"

# TODO: split into seperate classes
abstract struct AbstractVector
end

struct Vector < AbstractVector
  getter x, y, z

  X = Vector.new(1.0, 0.0, 0.0)
  Y = Vector.new(0.0, 1.0, 0.0)
  Z = Vector.new(0.0, 0.0, 1.0)

  ONE  = Vector.new(1.0)
  ZERO = Vector.new(0.0)

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
end

struct Point < AbstractVector
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

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end
end


struct Color < AbstractVector
  WHITE = self.new(1.0)
  BLACK = self.new(0.0)

  getter r, g, b

  def initialize
    @r, @g, @b = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @r, @g, @b = value, value, value
  end

  def initialize(@r : Float64, @g : Float64, @b : Float64)
  end

  def self.from_hex(hex)
    r = hex[1, 2].to_i(16).to_f / 255
    g = hex[3, 2].to_i(16).to_f / 255
    b = hex[5, 2].to_i(16).to_f / 255

    Color.new(r, g, b)
  end

  def mix(other : Color, t : Float64)
    Color.new(
      mix(@r, other.r, t),
      mix(@g, other.g, t),
      mix(@b, other.b, t),
    )
  end

  # TODO: use macros to dry this up
  def *(other : Float64)
    Color.new(@r * other, @g * other, @b * other)
  end

  def **(other : Float64)
    Color.new(@r ** other, @g ** other, @b ** other)
  end

  def /(other : Float64)
    Color.new(@r / other, @g / other, @b / other)
  end

  # TODO: use macros to dry this up
  def *(other : Color)
    Color.new(@r * other.r, @g * other.g, @b * other.b)
  end

  def +(other : Color)
    Color.new(@r + other.r, @g + other.g, @b + other.b)
  end

  def de_nan
    (@r.nan? || @g.nan? || @b.nan?) ? Color::BLACK : self
  end

  def min(other : Float64)
    Color.new(
      min(@r, other),
      min(@g, other),
      min(@b, other)
    )
  end
end

struct Point < AbstractVector
  def initialize
    @x, @y, @z = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @x, @y, @z = value, value, value
  end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
  end

  {% for op in %w(+ -) %}
    def {{op.id}}(other : (Value))
      Point.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end
  {% end %}

  {% for op in %w(-) %}
    def {{op.id}}(other : (Value))
      Point.new(@x {{op.id}} other.x, @y {{op.id}} other.y, @z {{op.id}} other.z)
    end
  {% end %}

  {% for op in %w(*) %}
    def {{op.id}}(other : (Float | Int))
      Point.new(@x {{op.id}} other, @y {{op.id}} other, @z {{op.id}} other)
    end
  {% end %}

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  def distance(point : Point)
    (self - point).length
  end

  def squared_distance(point : Point)
    (self - point).squared_length
  end

  # TODO: rename this to `to_tuple`
  def tuple
    {x, y, z}
  end

  def [](axis)
    if axis == 0
      @x
    elsif axis == 1
      @y
    else
      @z
    end
  end
end

struct Normal < AbstractVector
  getter x, y, z

  # def initialize
    # @x, @y, @z = 0.0, 0.0, 0.0
  # end

  # def initialize(value : Float64)
    # @x, @y, @z = value, value, value
  # end

  def initialize(@x : Float64, @y : Float64, @z : Float64)
    # TODO: add epsilon constant
    # TODO: cleanup
    if (self.dot(self) - 1.0).abs > 0.1
      p self
      raise "Error, length of normal is != 1"
    end
  end

  def *(other : Float64)
    Vector.new(@x * other, @y * other, @z * other)
  end

  def dot(other)
    @x * other.x + @y * other.y + @z * other.z
  end

  # TODO: is the result a normal?
  def cross(other)
    Vector.new(
      @y * other.z - @z * other.y,
      @z * other.x - @x * other.z,
      @x * other.y - @y * other.x
    )
  end

  def flip
    Normal.new(-@x, -@y, -@z)
  end

  # TODO: this is only used by onb.cr:14
  # in combination with pdf distributions around a normal
  def normalize
    self
  end

  def to_vector
    Vector.new(@x, @y, @z)
  end
end
