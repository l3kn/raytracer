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

