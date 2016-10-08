require "./material"
require "./aabb"

record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Point,
  normal : Normal,
  material : Material,
  u : Float64, # Vars for texture mapping
  v : Float64

abstract class Hitable
  abstract def hit(ray : Ray) : (HitRecord | Nil)

  def hit(ray : ExtendedRay) : (HitRecord | Nil)
    hit(Ray.new(ray.origin, ray.direction, ray.t_min, ray.t_max))
  end

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
    @bounding_box = AABB.new(Point.new(-Float64::MAX), Point.new(Float64::MAX))
  end
end
