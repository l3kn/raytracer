abstract class Light
  # TODO: Implement transformations for lights,
  # throw an error if the transfromations alters the scale

  # Take a point in the scene and return:
  #  * A vector from this point to the light
  #  * The color emitted in this direction
  #  * A VisibilityTester to check if the path to the light is unoccluded
  #  * The pdf for that vector / ray
  abstract def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}

  # Sample a random outgoing ray,
  abstract def sample_l : {Color, Ray, Normal, Float64}
  abstract def pdf(point : Point, wi : Vector) : Float64
  abstract def delta_light? : Bool
  abstract def power : Color
end

class PointLight < Light
  # def initialize(@transformation : Transformation, @intensity : Color)
    # @position = transformation.object_to_world(Point.new(0.0))
  def initialize(@position : Point, @intensity : Color); end

  def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}
    dist = (@position - point)
    wi = dist.normalize

    tester = VisibilityTester.from_segment(point, @position)

    {wi, @intensity / dist.squared_length, tester, 1.0}
  end

  def sample_l : {Color, Ray, Normal, Float64}
    dir = uniform_sample_sphere

    {
      @intensity,
      Ray.new(@position, dir),
      dir.to_normal,
      uniform_sphere_pdf
    }
  end

  def pdf(point, wi); 0.0; end
  def delta_light?; true; end

  def power
    @intensity * 4.0 * Math::PI
  end
end

class AreaLight < Light
  def initialize(@object : FiniteHitable, @intensity : Color); end

  def sample_l(normal : Normal, scene : Scene, point : Point) : {Vector, Color, VisibilityTester, Float64}
    point_s, normal_s = @object.sample(point)

    dist = point_s - point
    wi = dist.normalize

    tester = VisibilityTester.from_segment(point, point_s)

    # TODO: which version is the right one?
    # {wi, @intensity / dist.squared_length, tester, @object.pdf(point, wi)}
    {wi, @intensity, tester, @object.pdf(point, wi)}
  end

  def sample_l : {Color, Ray, Normal, Float64}
    origin, normal = @object.sample
    wi = cosine_sample_hemisphere
    dir_pdf = cosine_hemisphere_pdf(wi.z)

    onb = ONB.from_w(normal)
    wi_world = onb.local_to_world(wi) 

    {
      @intensity,
      Ray.new(origin, wi_world),
      normal,
      @object.pdf(origin) * dir_pdf
    }
  end

  def pdf(point, wi); @object.pdf(point, wi); end
  def delta_light?; false; end

  def power
    @intensity * @object.area * Math::PI
  end

  def self.with_object(object : Hitable, intensity : Color)
    light = self.new(object, intensity)
    object.area_light = light
    { object, light }
  end
end
