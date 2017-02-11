require "./matrix4"

class VisibilityTester
  def initialize(@ray = Ray.new(Point.zero, Vector.x))
  end

  def self.from_segment(p1 : Point, p2 : Point)
    dir = p2 - p1
    self.new(Ray.new(p1, dir, 0.001, dir.length))
  end

  def unoccluded?(scene : Scene)
    !scene.fast_hit(@ray)
  end
end

class Light
  # TODO: Make this class abstract
  # NOTE: The matrix in @transformation is from world to object space
  # def initialize(@transformation : Transformation)
  def initialize
    # TODO: Throw an error if the transformation alters the scale
    # bc/ this would cause errors
  end

  def sample_l(point : Point) : {Vector, Color, VisibilityTester, Float64}
    {Vector.zero, Color::BLACK, VisibilityTester.new, 0.0}
  end

  def power : Color
    Color::BLACK
  end

  def is_delta_light?
    false
  end

  def hit(ray) : HitRecord?
    nil
  end
end

class PointLight < Light
  # def initialize(@transformation : Transformation, @intensity : Color)
    # @position = transformation.object_to_world(Point.new(0.0))
  def initialize(@position : Point, @intensity : Color)
  end

  def sample_l(point : Point) : {Vector, Color, VisibilityTester, Float64}
    dist = (@position - point)
    wi = dist.to_normal.to_vector

    tester = VisibilityTester.from_segment(point, @position)

    {wi, @intensity / dist.squared_length, tester, 1.0}
  end

  def power
    @intensity * 4.0 * Math::PI
  end

  def is_delta_light?
    true
  end
end

class SpotLight < Light
  getter cos_total_width : Float64
  getter cos_falloff_start : Float64

  def initialize(@position : Point, @intensity : Color, @width : Float64, @fall : Float64)
    @cos_total_width = Math.cos(@width)
    @cos_falloff_start = Math.cos(@fall)
  end

  def sample_l(point : Point) : {Vector, Color, VisibilityTester, Float64}
    dist = (@position - point)
    wi = dist.to_normal.to_vector
    tester = VisibilityTester.from_segment(point, @position)

    int = @intensity * falloff(-wi) / dist.squared_length
    {wi, int, tester, 1.0}
  end
  
  def falloff(w : Vector) : Float64
    # TODO: Actually do some transformations
    # TODO: This should be w.z
    cos_theta = w.y.abs

    return 0.0 if (cos_theta < cos_total_width)
    return 1.0 if (cos_theta > cos_falloff_start)

    delta = (cos_theta - cos_total_width) / (cos_falloff_start - cos_total_width)
    delta ** 4
  end

  def power
    @intensity * 2.0 * Math::PI * (1.0 - 0.5 * (cos_falloff_start + cos_total_width))
  end

  def is_delta_light?
    true
  end
end

class ObjectLight < Light
  def initialize(@object : FiniteHitable, @intensity : Color)
  end

  def sample_l(point : Point) : {Vector, Color, VisibilityTester, Float64}
    own_point = @object.random
    dist = (own_point - point)
    wi = dist.to_normal.to_vector

    tester = VisibilityTester.from_segment(point, own_point)

    {wi, @intensity / dist.squared_length, tester, @object.pdf(own_point)}
  end

  def power
    @intensity * @object.area * Math::PI
  end

  def is_delta_light?
    false
  end
end
