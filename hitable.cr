struct Intersection
  getter t, point, normal, material

  def initialize(@t, @point, @normal, @material)
  end
end

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box.min.xyz[n]
  end
end

class Sphere < Hitable
  property center, radius, material

  def initialize(@center, @radius, @material)
  end

  def hit(ray, t_min, t_max)
    oc = ray.origin - center

    a = ray.direction.squared_length
    b = 2.0 * oc.dot(ray.direction)
    c = oc.squared_length - radius**2
    discriminant = b**2 - 4*a*c

    if discriminant > 0
      tmp = (-b - Math.sqrt(discriminant)) / (2.0*a)

      if (tmp < t_max && tmp > t_min)
        point = ray.point_at_parameter(tmp)
        normal = (point - center) / radius
        return Intersection.new(tmp, point, normal, @material)
      end

      tmp = (-b + Math.sqrt(discriminant)) / (2.0*a)

      if (tmp < t_max && tmp > t_min)
        point = ray.point_at_parameter(tmp)
        normal = (point - center) / radius
        return Intersection.new(tmp, point, normal, @material)
      end

      return nil
    end
  end

  def bounding_box
    r = Vec3.new(radius)
    AABB.new(@center - r, @center + r)
  end
end

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
