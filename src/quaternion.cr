require "linalg"

struct Quaternion < LA::AQuaternion
  def initialize(@x, @y, @z, @w)
  end

  def initialize(@x : Float64, yzw : (Point | Vector))
    @y, @z, @w = yzw.xyz
  end

  def initialize(xyz : (Point | Vector), @w : Float64)
    @x, @y, @z = xyz.xyz
  end

  define_vector_swizzling(3, target: Vector, signed: true)
end
