require "linalg"

module Vectorlike
  def max_axis
    @x >= @y && @x >= @z ? 0 : (@y >= @x && @y >= @z ? 1 : 2)
  end

  def [](axis)
    {@x, @y, @z}[axis]
  end

  def max_component
    max(@x, max(@y, @z))
  end

  def to_tuple
    {@x, @y, @z}
  end

  def to_vector
    Vector.new(@x, @y, @z)
  end

  def to_point
    Point.new(@x, @y, @z)
  end
end

struct Vector < LA::AVector3
  define_class_methods
  define_dot(other_class: Normal)
  define_vector_op(:*)
  define_vector_op(:/)
  define_vector_swizzling(2)
  define_vector_swizzling(3, signed: true)

  include Vectorlike

  def to_normal
    inv = 1.0 / length
    Normal.new(self.x * inv, self.y * inv, self.z * inv)
  end

  def max(other : Float64)
    Vector.new(max(@x, other), max(@y, other), max(@z, other))
  end
end

struct Point < LA::AVector3
  define_vector_op(:+, other_class: Vector, result_class: Point)
  define_vector_op(:-, other_class: Vector, result_class: Point)
  define_vector_op(:-, other_class: Point, result_class: Vector)
  define_dot(other_class: Vector)
  define_dot(other_class: Normal)
  define_vector_swizzling(3, target: Point, signed: true)
  define_vector_swizzling(2, target: Tuple, signed: true)

  include Vectorlike

  def initialize(@x, @y, @z); end

  def initialize(value)
    @x = @y = @z = value
  end

  def initialize(xy : Tuple, @z : Float64)
    @x, @y = xy
  end

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  def squared_distance(other : Point)
    (self - other).squared_length
  end

  # TODO: the methods below are only needed for some DE Primitives
  def abs
    Point.new(@x.abs, @y.abs, @z.abs)
  end
end

struct Normal < LA::AVector3
  define_dot(other_class: Vector)
  define_vector_op(:+, other_class: Normal, result_class: LA::Vector3)
  define_vector_op(:-, other_class: Normal, result_class: LA::Vector3)
  define_op(:*, other_class: Float64, result_class: Vector)

  include Vectorlike

  def initialize(@x : Float64, @y : Float64, @z : Float64)
    assert((self.dot(self) - 1.0).abs < EPSILON)
  end

  def face_forward(v)
    dot(v) < 0.0 ? -self : self
  end

  def refract(wi : Vector, eta : Float64) : Vector?
    cos_theta_i = dot(wi.normalize)
    sin_2_theta_i = max(0.0, 1.0 - cos_theta_i * cos_theta_i)
    sin_2_theta_t = eta * eta * sin_2_theta_i

    if sin_2_theta_t >= 1.0
      nil
    else
      cos_theta_t = Math.sqrt(1.0 - sin_2_theta_t)
      -wi * eta + self * (eta * cos_theta_i - cos_theta_t)
    end
  end
end
