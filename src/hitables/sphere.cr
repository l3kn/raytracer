require "../hitable"

class Sphere < FiniteHitable
  property center, radius, material

  def initialize(@center : Point, @radius : Float64, @material : Material)
    r = Vector.new(@radius)
    @bounding_box = AABB.new(@center - r, @center + r)
  end

  def hit(ray)
    oc = ray.origin - center

    a = ray.direction.squared_length
    b = 2.0 * oc.dot(ray.direction)
    c = oc.squared_length - radius**2

    ts = solve_quadratic(a, b, c)
    return nil if ts.nil?

    t0, t1 = ts
    # We know that t0 < t1
    #     t0 > t_max 
    #  => t1 > t_max
    #  => no hit
    return nil if t0 > ray.t_max || t1 < ray.t_min

    t_hit = t0
    if t0 < ray.t_min
      t_hit = t1
      return nil if t_hit > ray.t_max
    end

    point = ray.point_at_parameter(t_hit)

    # This should be a bit faster than (point - center).to_normal
    inv = 1.0 / @radius
    normal = Normal.new(
      (point.x - center.x) * inv,
      (point.y - center.y) * inv,
      (point.z - center.z) * inv,
    )

    u = 0.5 + Math.atan2(-normal.z, -normal.x) / (2 * Math::PI)
    v = 0.5 - Math.asin(-normal.y) / Math::PI

    return HitRecord.new(t_hit, point, normal, @material, u, v)
  end

  def pdf_value(origin, direction)
    hit = hit(Ray.new(origin, direction))

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
