class Scene
  property hitable : Hitable
  property lights : Array(Light)
  property background : Background

  def initialize(hitables, @lights, @background)
    if hitables.size < 500
      @hitable = HitableList.new(hitables)
    else
      finite = hitables.select(&.is_a?(FiniteHitable)).map(&.as(FiniteHitable))
      infinite = hitables.reject(&.is_a?(FiniteHitable))

      if infinite.size > 0
        @hitable = HitableList.new([SAHBVHNode.new(finite)] + infinite)
      else
        @hitable = SAHBVHNode.new(finite)
      end
    end
  end

  def hit(ray : Ray) : HitRecord?
    @hitable.hit(ray)
  end

  def fast_hit(ray : Ray) : Bool
    # TODO: actually implement a fast hit method for some hitables
    !hit(ray).nil?
  end

  # TODO: Use this for uniform_sample_*_light(s) ?
  def light_sampling_CDF
    Distribution1D.new(@lights.map(&.power.length))
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
