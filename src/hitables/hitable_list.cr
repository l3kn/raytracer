module Hitable
  # Methods shared between `List` and `BoundedList`
  #
  # NOTE: Inheritance is not possible,
  # because `List < UnboundedHitable`
  # but `BoundedList < BoundedHitable`
  module ListMethods
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

  class List < UnboundedHitable
    include ListMethods

    def initialize(@objects : Array(UnboundedHitable)); end
  end

  class BoundedList < BoundedHitable
    include ListMethods

    def initialize(list : Array(BoundedHitable))
      @objects = Array(BoundedHitable).new
      @bounding_box = list[0].bounding_box

      list.each do |object|
        @objects << object
        @bounding_box = @bounding_box.merge(object.bounding_box)
      end
    end
  end
end
