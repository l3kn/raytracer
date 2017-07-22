abstract class Light
  # TODO: Implement transformations for lights,
  # throw an error if the transformation alters the scale

  # Take a point in the scene and return:
  #  * A vector from this point to the light
  #  * The color emitted in this direction
  #  * A VisibilityTester to check if the path to the light is unoccluded
  #  * The pdf for that vector / ray
  abstract def sample_l(normal : Normal, scene : Scene, point : Point) : LightIncomingSample

  # Sample a random outgoing ray,
  abstract def sample_l : LightOutgoingSample
  abstract def pdf(point : Point, wi : Vector) : Float64
  abstract def delta_light? : Bool
  abstract def power : Color
end

record LightIncomingSample, dir : Vector, color : Color, tester : VisibilityTester, pdf : Float64 do
  def relevant?
    !(@pdf == 0.0 || @color.black?)
  end
end

record LightOutgoingSample, ray : Ray, color : Color, normal : Normal, pdf : Float64 do
  def relevant?
    !(@pdf == 0.0 || @color.black?)
  end
end

class PointLight < Light
  # def initialize(@transformation : Transformation, @intensity : Color)
  # @position = transformation.object_to_world(Point.new(0.0))
  def initialize(@position : Point, @intensity : Color); end

  def sample_l(normal : Normal, scene : Scene, point : Point)
    dist = (@position - point)
    wi = dist.normalize

    LightIncomingSample.new(
      wi,
      @intensity / dist.squared_length,
      VisibilityTester.from_segment(point, @position),
      1.0
    )
  end

  def sample_l
    dir = uniform_sample_sphere

    LightOutgoingSample.new(
      Ray.new(@position, dir),
      @intensity,
      dir.to_normal,
      uniform_sphere_pdf
    )
  end

  def pdf(point, wi)
    0.0
  end

  def delta_light?
    true
  end

  def power
    @intensity * 4.0 * Math::PI
  end
end

class AreaLight < Light
  def initialize(@object : BoundedHitable, @intensity : Color); end

  def sample_l(normal : Normal, scene : Scene, point : Point)
    point_s, normal_s = @object.sample(point)

    dist = point_s - point
    wi = dist.normalize

    # TODO: Does @intensity need to be divided by dist.squared_length?
    LightIncomingSample.new(
      wi,
      @intensity,
      VisibilityTester.from_segment(point, point_s),
      @object.pdf(point, wi)
    )
  end

  def sample_l
    origin, normal = @object.sample
    wi = cosine_sample_hemisphere
    dir_pdf = cosine_hemisphere_pdf(wi.z)

    onb = ONB.from_w(normal)
    wi_world = onb.local_to_world(wi)

    LightOutgoingSample.new(
      Ray.new(origin, wi_world),
      @intensity,
      normal,
      @object.pdf(origin) * dir_pdf
    )
  end

  def pdf(point, wi)
    @object.pdf(point, wi)
  end

  def delta_light?
    false
  end

  def power
    @intensity * @object.area * Math::PI
  end

  def self.with_object(object : Hitable, intensity : Color)
    light = self.new(object, intensity)
    object.area_light = light
    {object, light}
  end
end
