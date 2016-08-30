class Sphere < Hitable
  property center, radius, material

  def initialize(@center : Vec3, @radius : Float64, @material : Material)
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

        # Naive:
        #   u = Math.asin(normal.x) / Math::PI + 0.5
        #   v = Math.asin(normal.y) / Math::PI + 0.5
        u = 0.5 + Math.atan2(-normal.z, -normal.x) / (2 * Math::PI)
        v = 0.5 - Math.asin(-normal.y) / Math::PI
        return HitRecord.new(tmp, point, normal, @material, u, v)
      end

      tmp = (-b + Math.sqrt(discriminant)) / (2.0*a)

      if (tmp < t_max && tmp > t_min)
        point = ray.point_at_parameter(tmp)
        normal = (point - center) / radius

        u = Math.atan2(-normal.z, -normal.x) / (2 * Math::PI) + 0.5
        v = Math.asin(-normal.y) / Math::PI + 0.5
        return HitRecord.new(tmp, point, normal, @material, u, v)
      end

      return nil
    end
  end

  def bounding_box
    r = Vec3.new(radius)
    AABB.new(@center - r, @center + r)
  end

  def pdf_value(origin, direction)
    hit = hit(Ray.new(origin, direction), 0.001, Float64::MAX)

    if hit
      cos_theta_max = Math.sqrt(1.0 - @radius*@radius / (@center - origin).squared_length)
      solid_angle = 2.0*Math::PI*(1.0 - cos_theta_max)
      1.0 / solid_angle
    else
      0.0
    end
  end

  def random(origin)
    direction = @center - origin
    distance_squared = direction.squared_length

    uvw = ONB.from_w(direction)
    uvw.local(random_to_sphere(@radius, distance_squared))
  end
end
