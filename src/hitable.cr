record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Point,
  normal : Normal,
  material : Material,
  object : Hitable,
  u : Float64, # Vars for texture mapping
  v : Float64

abstract class Hitable
  property area_light : Light?
  @area_light = nil

  abstract def hit(ray : Ray) : HitRecord?

  def hit(ray : ExtendedRay) : HitRecord?
    hit(Ray.new(ray.origin, ray.direction, ray.t_min, ray.t_max))
  end

  def pdf_value(origin, direction)
    raise "Error, this feature is not supported yet"
  end

  def sample : {Point, Normal}
    raise "Error, this feature is not supported yet"
  end

  def sample(origin) : {Point, Normal}
    sample
  end

  # What is the probability that the object was hit in point?
  def pdf(point : Point) : Float64
    1.0 / area
  end

  # Probability that a ray(point, wi)
  # hits the light
  # (used for area lights)
  def pdf(point : Point, wi : Vector) : Float64
    hit = hit(Ray.new(point, wi))
    if hit && hit.normal.dot(wi) < 0.0
      pdf(hit.point)
    else
      0.0
    end
    # if hit
    #   puts (point - hit.point).squared_length / hit.normal.dot(-wi).abs * area
    #   (hit.point - point).squared_length / hit.normal.dot(-wi).abs * area
    # else
    #   0.0
    # end
  end

  # Area of this object
  def area : Float64
    raise "Error, this feature is not supported yet"
  end
end

abstract class FiniteHitable < Hitable
  property bounding_box : AABB

  # TODO: Would removing this break anything?
  def initialize
    @bounding_box = AABB.new(Point.new(-Float64::MAX), Point.new(Float64::MAX))
  end
end
