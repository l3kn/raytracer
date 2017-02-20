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
