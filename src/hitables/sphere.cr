require "../hitable"

class Sphere < FiniteHitable
  property material

  def initialize(@material : Material)
    @bounding_box = AABB.new(Point.new(-1.0), Point.new(1.0))
  end

  def hit(ray)
    oc = ray.origin

    a = ray.direction.squared_length
    b = 2.0 * oc.dot(ray.direction)
    c = oc.squared_length - 1.0

    ts = solve_quadratic(a, b, c)
    return nil if ts.nil?

    t0, t1 = ts
    return nil if t0 > ray.t_max || t1 < ray.t_min

    t_hit = t0
    if t0 < ray.t_min
      t_hit = t1
      return nil if t_hit > ray.t_max
    end

    point = ray.point_at_parameter(t_hit)

    # This only works bc/ radius = 1.0
    normal = Normal.new(point.x, point.y, point.z)

    u = 0.5 + Math.atan2(-normal.z, -normal.x) * 0.5 * INV_PI
    v = 0.5 - Math.asin(-normal.y) * INV_PI

    return HitRecord.new(t_hit, point, normal, @material, self, u, v)
  end

  # TODO: Delete this once the new pdf methods are in place
  # def pdf_value(origin, direction)
  #   hit = hit(Ray.new(origin, direction))

  #   if hit
  #     cos_theta_max = Math.sqrt(1.0 - @radius*@radius / (@center - origin).squared_length)
  #     solid_angle = 2.0*Math::PI*(1.0 - cos_theta_max)
  #     1.0 / solid_angle
  #   else
  #     0.0
  #   end
  # end

  # def random(origin : Point)
  #   direction = @center - origin
  #   distance_squared = direction.squared_length

  #   uvw = ONB.from_w(direction)
  #   uvw.local(random_to_sphere(@radius, distance_squared))
  # end
end
