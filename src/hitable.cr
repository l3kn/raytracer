require "./material"
require "./aabb"

record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Vec3,
  normal : Vec3,
  material : Material,
  u : Float64, # Vars for texture mapping
  v : Float64

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (HitRecord | Nil)

  def pdf_value(origin, direction)
    raise "Error, this feature is not supported yet"
  end

  def random(origin)
    raise "Error, this feature is not supported yet"
  end
end

abstract class FiniteHitable < Hitable
  property bounding_box : AABB

  def initialize
    @bounding_box = AABB.new(Vec3::ZERO, Vec3::ZERO)
  end
end

abstract class Geometry
  abstract def hit(ray : Ray, t_min : Float64, t_max : Float64) : (HitRecord | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box
  end
end
