module HitableListMethods
  def hit(ray)
    result = nil
    closest_so_far = ray.t_max

    @objects.each do |object|
      rec = object.hit(Ray.new(ray.origin, ray.direction, ray.t_min, closest_so_far))
      if rec
        closest_so_far = rec.t
        result = rec
      end
    end

    result
  end

  def area
    res = 0.0
    @objects.each do |object|
      res += object.area
    end
    res
  end

  def pdf(point, wi)
    res = 0.0
    @objects.each do |obj|
      res += obj.pdf(point, wi)
    end
    res / @objects.size
  end

  def sample
    @objects.sample.sample
  end

  def sample(origin)
    @objects.sample.sample(origin)
  end
end

class HitableList < Hitable
  include HitableListMethods

  def initialize(@objects : Array(Hitable))
  end
end

# TODO: find a way to do this with less code duplication
class FiniteHitableList < FiniteHitable
  include HitableListMethods

  def initialize(list : Array(FiniteHitable))
    @objects = Array(FiniteHitable).new
    @bounding_box = list[0].bounding_box

    list.each do |object|
      @objects << object
      @bounding_box = @bounding_box.merge(object.bounding_box)
    end
  end
end
