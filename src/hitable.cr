require "./material"
require "./aabb"

record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Point,
  normal : Normal,
  material : Material,
  u : Float64, # Vars for texture mapping
  v : Float64

record Intersection,
  t : Float64, # Ray parameter of the hitpoint
  point : Point,
  normal : Normal,
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

class Primitive < Hitable
  property shape : Shape
  property material : Material

  def initialize(@shape, @material)
  end

  def hit(ray : Ray, t_min : Float, t_max : Float) : (HitRecord | Nil)
    intersection = @shape.intersect(ray, t_min, t_max)

    HitRecord.new(
      intersection.t,
      intersection.point,
      intersection.normal,
      @material,
      intersection.u,
      intersection.v,
    )
  end

  def pdf_value(origin, direction)
    raise "Error, this feature is not supported yet"
  end

  def random(origin)
    raise "Error, this feature is not supported yet"
  end
end

abstract class Shape
  abstract def intersect(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)

  # Used for shadow rays
  def intersect_fast(ray : Ray, t_min : Float, t_max : Float) : Bool
    !intersect(ray, t_min, t_max).nil?
  end
end

abstract class FiniteHitable < Hitable
  property bounding_box : AABB

  def initialize
    @bounding_box = AABB.new(Point.new(-Float64::MAX), Point.new(Float64::MAX))
  end
end

abstract class Geometry
  abstract def hit(ray : Ray, t_min : Float64, t_max : Float64) : (HitRecord | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box
  end
end
