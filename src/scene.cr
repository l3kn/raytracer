class Scene
  property hitable : Hitable
  property lights : Array(Light)
  property background : Background
  # property bounding_sphere_center : Point
  # property bounding_sphere_radius : Float64

  def initialize(hitables, @lights, @background)
    if hitables.size < 500
      @hitable = HitableList.new(hitables)
      puts "Constructing hitable list"
    else
      finite = hitables.select(&.is_a?(FiniteHitable)).map(&.as(FiniteHitable))
      infinite = hitables.reject(&.is_a?(FiniteHitable))

      if infinite.size > 0
        @hitable = HitableList.new(
          [SAHBVHNode.new(finite)] + infinite
        )
        puts "Constructing BVH + infinite list"
      else
        @hitable = SAHBVHNode.new(finite)
        puts "Constructing BVH"
      end
    end
  end

  def hit(ray : Ray) : HitRecord?
    @hitable.hit(ray)
  end

  def fast_hit(ray : Ray) : Bool
    !hit(ray).nil?
  end
end
