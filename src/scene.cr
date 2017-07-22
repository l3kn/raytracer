class Scene
  property hitable : UnboundedHitable
  property lights : Array(Light)
  property background : ABackground?
  property light_sampling_CDF do
    Distribution1D.new(lights.map(&.power.length))
  end

  def initialize(hitables, @lights = [] of Light, @background = nil)
    if hitables.size < 5
      @hitable = HitableList.new(hitables)
    else
      finite = hitables.select(&.is_a?(BoundedHitable)).map(&.as(BoundedHitable))
      infinite = hitables.reject(&.is_a?(BoundedHitable))

      if infinite.size > 0
        @hitable = HitableList.new([SAHBVHNode.new(finite)] + infinite)
      else
        @hitable = SAHBVHNode.new(finite)
      end
    end
  end

  def get_background(ray)
    background = @background
    background.nil? ? Color::BLACK : background.get(ray)
  end

  def hit(ray : Ray) : HitRecord?
    @hitable.hit(ray)
  end

  def fast_hit(ray : Ray) : Bool
    # TODO: actually implement a fast hit method for some hitables
    !hit(ray).nil?
  end
end

class VisibilityTester
  def initialize(@ray : Ray); end

  def self.from_segment(p1 : Point, p2 : Point)
    dir = p2 - p1
    new(Ray.new(p1, dir.normalize, EPSILON, dir.length - EPSILON))
  end

  def unoccluded?(scene : Scene)
    !scene.fast_hit(@ray)
  end
end
