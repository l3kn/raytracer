class HitableList
  property objects, bounding_box

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

  def push(obj)
    @objects << object
    @bounding_box = @bounding_box.merge(object.bounding_box)
  end
end
