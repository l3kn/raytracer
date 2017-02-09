class Scene
  property hitable : Hitable
  property lights : Array(Light)
  property background : Background

  def initialize(hitables, @lights, @background = ConstantBackground.new(Color::WHITE))
    if hitables.size > 1000
      @hitable = HitableList.new(hitables)
    else
      finite = hitables.select(&.is_a?(FiniteHitable)).map(&.as(FiniteHitable))
      infinite = hitables.reject(&.is_a?(FiniteHitable))

      if infinite.size > 0
        @hitable = HitableList.new(
          [SAHBVHNode.new(finite)] + infinite
        )
      else
        @hitable = SAHBVHNode.new(finite)
      end
    end
  end

  def hit(ray : Ray) : (HitRecord | Nil)
    @hitable.hit(ray)
  end

  def fast_hit(ray : Ray) : Bool
    !hit(ray).nil?
  end
end
