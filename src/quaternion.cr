require "linalg"

struct Quaternion < LA::AQuaternion
  def initialize(@x, @y, @z, @w)
  end

  def initialize(@x : Float64, yzw : (Point | Vector))
    @y, @z, @w = yzw.to_tuple
  end

  def initialize(xyz : (Point | Vector), @w : Float64)
    @x, @y, @z = xyz.to_tuple
  end

  def conjugate
    Quaternion.new(@x, -@y, -@z, -@w)
  end

  def squared_length
    @x*@x + @y*@y + @z*@z + @w*@w
  end

  def inverse
    inv = 1.0 / squared_length
    Quaternion.new(@x * inv, -@y * inv, -@z * inv, -@w * inv)
  end

  define_vector_swizzling(3, target: Vector, signed: true)
end
