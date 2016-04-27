struct Intersection
  getter t, point, normal, material

  def initialize(@t, @point, @normal, @material)
  end
end

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)
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
end

class HitableList < Hitable
  property objects

  def initialize
    @objects = Array(Hitable).new # TODO: use abstract object class
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

  def push(object)
    objects << object
  end
end
