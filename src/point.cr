require "linalg"
require "./vector"

struct Point < LA::AVector3
  define_vector_op(:+, other_class: Vector, result_class: Point)
  define_vector_op(:-, other_class: Vector, result_class: Point)

  define_vector_op(:-, other_class: Point, result_class: Vector)

  def initialize(value)
    @x = @y = @z = value
  end

  def initialize(@x, @y, @z)
  end

  def initialize(xy : Tuple, @z : Float64)
    @x = xy[0]
    @y = xy[1]
  end

  # TODO: this is somewhat inconsisten,
  # this method is only needed by the optimized `Transformation.object_to_world(box : AABB)` 
  # => this is already done by importing from the abstract struct 
  #    define_vector_op(:+, other_class: Point, result_class: Point)

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  define_dot(other_class: Vector)
  define_dot(other_class: Normal)

  # TODO: the methods below are only needed for some DE Primitives
  def abs
    Point.new(@x.abs, @y.abs, @z.abs)
  end

  define_vector_swizzling(3, target: Point, signed: true)
  define_vector_swizzling(2, target: Tuple, signed: true)

  # TODO: this is somewhat inconsistent with the swizzling methods above
  def xyz; {@x, @y, @z}; end

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
