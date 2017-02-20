class LightHitable < FiniteHitable
  def initialize(@hitable : FiniteHitable, @light : Light)
    @bounding_box = @hitable.bounding_box
  end

  def hit(ray)
    hit = @hitable.hit(ray)
    return nil if hit.nil?

    HitRecord.new(
      hit.t,
      hit.point,
      hit.normal,
      hit.material,
      self,
      hit.u, hit.v
    )
  end

  def pdf_value(origin, direction)
    @hitable.pdf_value(origin, direction)
  end

  def sample
    @hitable.sample
  end

  def sample(origin)
    @hitable.sample(origin)
  end

  def pdf(point : Point) : Float64
    @hitable.pdf(point)
  end

  def pdf(point : Point, wi : Vector) : Float64
    @hitable.pdf(point, wi)
  end

  # Area of this object
  def area : Float64
    @hitable.area
  end

  def area_light
    @light
  end
end

class VisibilityTester
  def initialize(@ray = Ray.new(Point.zero, Vector.x))
  end

  def self.from_segment(p1 : Point, p2 : Point)
    dir = p2 - p1
    new(Ray.new(p1, dir.normalize, EPSILON, dir.length - EPSILON))
  end

  def unoccluded?(scene : Scene)
    !scene.fast_hit(@ray)
  end
end

abstract class Light
  # TODO: Throw an error if the transformation alters the scale
  # bc/ this would cause errors
  # def initialize(@transformation : Transformation)
  def initialize
  end

  # Take a point in the scene and return:
  #  * A vector from this point to the light
  #  * The color emitted in this direction
  #  * A VisibilityTester to check if the path to the light is unoccluded
  #  * The pdf for that vector / ray
  # TODO: return nil if there is no sample
  def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}
    {Vector.zero, Color::BLACK, VisibilityTester.new, 0.0}
  end

  def pdf(point : Point, wi : Vector)
    0.0
  end

  def delta_light?
    false
  end
end

class PointLight < Light
  # def initialize(@transformation : Transformation, @intensity : Color)
    # @position = transformation.object_to_world(Point.new(0.0))
  def initialize(@position : Point, @intensity : Color)
  end

  def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}
    dist = (@position - point)
    wi = dist.normalize

    tester = VisibilityTester.from_segment(point, @position)

    {wi, @intensity / dist.squared_length, tester, 1.0}
  end

  def delta_light?
    true
  end
end

class AreaLight < Light
  def initialize(@object : FiniteHitable, @intensity : Color)
  end

  def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}
    point_s, normal_s = @object.sample(point)

    dist = point_s - point
    wi = dist.normalize

    tester = VisibilityTester.from_segment(point, point_s)
    {wi, @intensity / dist.squared_length, tester, @object.pdf(point, wi)}
  end

  def pdf(point, wi)
    @object.pdf(point, wi)
  end

  def delta_light?
    false
  end
end
