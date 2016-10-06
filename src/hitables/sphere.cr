require "../hitable"

class Sphere < FiniteHitable
  property center, radius, material

  def initialize(@center : Point, @radius : Float64, @material : Material)
    r = Vector.new(@radius)
    @bounding_box = AABB.new(@center - r, @center + r)
  end

  def hit(ray, t_min, t_max)
    oc = ray.origin - center

    a = ray.direction.squared_length
    b = 2.0 * oc.dot(ray.direction)
    c = oc.squared_length - radius**2

    ts = solve_quadratic(a, b, c)
    return nil if ts.nil?

    t0, t1 = ts
    return nil if t0 > t_max || t1 < t_min

    t_hit = t0
    if t0 < t_min
      t_hit = t1
      return nil if t_hit > t_max
    end

    point = ray.point_at_parameter(t_hit)

    # normal = (point - center).to_normal
    # We already know the length of (point - center),
    # so doing this should be a little bit faster
    inv = 1.0 / @radius
    normal = Normal.new(
      (point.x - center.x) * inv,
      (point.y - center.y) * inv,
      (point.z - center.z) * inv,
    )

    # Naive:
    #   u = Math.asin(normal.x) / Math::PI + 0.5
    #   v = Math.asin(normal.y) / Math::PI + 0.5
    u = 0.5 + Math.atan2(-normal.z, -normal.x) / (2 * Math::PI)
    v = 0.5 - Math.asin(-normal.y) / Math::PI
    return HitRecord.new(t_hit, point, normal, @material, u, v)
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

  def random(origin : Point)
    direction = @center - origin
    distance_squared = direction.squared_length

    uvw = ONB.from_w(direction)
    uvw.local(random_to_sphere(@radius, distance_squared))
  end
end
