require "../hitable"
require "../aabb"

class HitableList < Hitable
  property objects, bounding_box : AABB

  def initialize(list)
    @objects = Array(Hitable).new
    @bounding_box = list[0].bounding_box

    list.each do |object|
      @objects << object
      @bounding_box = @bounding_box.merge(object.bounding_box)
    end
  end

  def hit(ray, t_min, t_max)
    result = nil
    closest_so_far = t_max

    objects.each do |object|
      record = object.hit(ray, t_min, closest_so_far)
      if record
        closest_so_far = record.t
        result = record
      end
    end

    result
  end

  def pdf_value(origin, direction)
    weight = 1.0 / @objects.size
    sum = 0.0

    @objects.each do |obj|
      sum += weight * obj.pdf_value(origin, direction)
    end

    sum
  end

  def random(origin)
    index = (@objects.size * pos_random).to_i
    @objects[index].random(origin)
  end
end
