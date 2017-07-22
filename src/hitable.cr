# Container for all kinds of parameters
# about an intersection between a `Ray`
# and some `Hitable`.
struct HitRecord
  # Parameter of the ray at which the intersection occured
  getter t : Float64
  getter point : Point

  # `Normal` of the `Hitable`
  # at the point it was hit in
  getter normal : Normal

  # `Material` of the `Hitable`
  # at the point it was hit in
  getter material : Material

  # The actual object that was hit.
  # NOTE: This is only needed for area lights right now
  getter object : Hitable

  # Texture coordinates of the hit point
  getter u : Float64, v : Float64

  def initialize(@t, @point, @normal, @material, @object, @u, @v); end
end

# Superclass for any kind of 'object'
# we would want to calculate an intersection with.
abstract class Hitable
  property area_light : Light? = nil
  @area_light = nil

  abstract def hit(ray : Ray) : HitRecord?

  # Get a random point and its normal
  # somewhere on the object
  def sample : {Point, Normal}
    raise "Error, this feature is not supported yet"
  end

  # Get a random point and its normal
  # somewhere on the object with respect to some origin point.
  # This way it is possible to sample only the visible hemisphere
  # of a sphere etc.
  #
  # NOTE: For now this just points to `sample()`
  def sample(origin) : {Point, Normal}
    sample
  end

  # Probability density function
  # of points on the object.
  #
  # NOTE: For now this is always `1.0 / area`
  def pdf(point : Point) : Float64
    1.0 / area
  end

  # Probability density function
  # of rays 
  # Probability that a ray(point, wi)
  # hits the object
  def pdf(point : Point, wi : Vector) : Float64
    hit = hit(Ray.new(point, wi))
    return 0.0 if hit.nil?

    point.squared_distance(hit.point) / (hit.normal.dot(-wi).abs * area)
  end

  # TODO: This only makes sense for finite objects
  def area : Float64
    raise "Error, this feature is not supported yet"
  end
end

abstract class BoundedHitable < Hitable
  property bounding_box : AABB

  def initialize
    @bounding_box = AABB.new
  end
end
