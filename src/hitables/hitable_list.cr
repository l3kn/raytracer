module HitableListMethods
  def hit(ray)
    result = nil
    closest_so_far = ray.t_max

    @objects.each do |object|
      hit = object.hit(Ray.new(ray.origin, ray.direction, ray.t_min, closest_so_far))
      if hit
        closest_so_far = hit.t
        result = hit
      end
    end

    result
  end

  def area
    @objects.reduce(0.0) { |acc, obj| acc + obj.area }
  end

  def pdf(point, wi)
    @objects.reduce(0.0) { |acc, obj| acc + obj.pdf(point, wi) } / @objects.size
  end

  def sample
    @objects.sample.sample
  end

  def sample(origin)
    @objects.sample.sample(origin)
  end
end

class HitableList < UnboundedHitable
  include HitableListMethods

  def initialize(@objects : Array(UnboundedHitable)); end
end

# TODO: find a way to do this with less code duplication
class BoundedHitableList < BoundedHitable
  include HitableListMethods

  def initialize(list : Array(BoundedHitable))
    @objects = Array(BoundedHitable).new
    @bounding_box = list[0].bounding_box

    list.each do |object|
      @objects << object
      @bounding_box = @bounding_box.merge(object.bounding_box)
    end
  end
end
