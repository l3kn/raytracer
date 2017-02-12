record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Point,
  normal : Normal,
  material : Material,
  # emitted : Color,
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

  def random
    raise "Error, this feature is not supported yet"
  end

  def random(origin) : Vector
    raise "Error, this feature is not supported yet"
  end

  # What is the probability that the object was hit in point?
  def pdf(point : Point) : Float64
    1.0 / area
  end

  # Probability ray to point w/ direction wi
  # came from this Hitable
  # (used for area lights)
  def pdf(point : Point, wi : Vector) : Float64
    hit = hit(Ray.new(point, wi))
    if hit
      (hit.point - point).squared_length / hit.normal.dot(-wi).abs * area
    else
      return 0.0
    end
  end

  # Area of this object
  def area : Float64
    raise "Error, this feature is not supported yet"
  end
end

abstract class FiniteHitable < Hitable
  property bounding_box : AABB

  def initialize
    @bounding_box = AABB.new(Point.new(-Float64::MAX), Point.new(Float64::MAX))
  end
end
