struct HitRecord
  getter t : Float64
  getter point : Point
  getter normal : Normal
  getter material : Material
  getter object : UnboundedHitable
  getter u : Float64, v : Float64

  def initialize(@t, @point, @normal, @material, @object, @u, @v); end
end

abstract class UnboundedHitable
  property area_light : Light? = nil
  @area_light = nil

  abstract def hit(ray : Ray) : HitRecord?

  def sample : {Point, Normal}
    raise "Error, this feature is not supported yet"
  end

  def sample(origin) : {Point, Normal}
    sample
  end

  def pdf(point : Point) : Float64
    1.0 / area
  end

  # Probability that a ray(point, wi)
  # hits the object
  def pdf(point : Point, wi : Vector) : Float64
    hit = hit(Ray.new(point, wi))
    return 0.0 if hit.nil?

    point.squared_distance(hit.point) / (hit.normal.dot(-wi).abs * area)
  end

  # TODO: This only makes sense for finite objects
  # Area of this object
  def area : Float64
    raise "Error, this feature is not supported yet"
  end
end

abstract class BoundedHitable < UnboundedHitable
  property bounding_box : AABB

  def initialize
    @bounding_box = AABB.new
  end
end
