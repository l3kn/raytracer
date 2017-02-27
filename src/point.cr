struct Point < LA::AVector3
  define_vector_op(:+, other_class: Vector, result_class: Point)
  define_vector_op(:-, other_class: Vector, result_class: Point)
  define_vector_op(:-, other_class: Point, result_class: Vector)
  define_dot(other_class: Vector)
  define_dot(other_class: Normal)
  define_vector_swizzling(3, target: Point, signed: true)
  define_vector_swizzling(2, target: Tuple, signed: true)

  def initialize(value)
    @x = @y = @z = value
  end

  def initialize(@x, @y, @z)
  end

  def initialize(xy : Tuple, @z : Float64)
    @x = xy[0]
    @y = xy[1]
  end

  def max(other : Point)
    Point.new(max(@x, other.x), max(@y, other.y), max(@z, other.z))
  end

  def min(other : Point)
    Point.new(min(@x, other.x), min(@y, other.y), min(@z, other.z))
  end

  # TODO: the methods below are only needed for some DE Primitives
  def abs
    Point.new(@x.abs, @y.abs, @z.abs)
  end

  def squared_distance(other : Point)
    (self - other).squared_length
  end

  def to_tuple; {@x, @y, @z}; end
  def to_vector; Vector.new(@x, @y, @z); end

  def [](axis)
    {@x, @y, @z}[axis]
  end
end
