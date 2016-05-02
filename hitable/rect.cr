class XYRect < Hitable
  property x0, x1, y0, y1, z, material

  def initialize(@x0, @x1, @y0, @y1, @z, @material)
  end

  def hit(ray, t_min, t_max)
    t = (z - ray.origin.z) / ray.direction.z

    return nil if t < t_min || t > t_max

    point = ray.point_at_parameter(t)

    # Hitpoint is outside of the rect
    return nil if point.x < x0 || point.x > x1 ||
                  point.y < y0 || point.y > y1

    normal = Vec3.new(0.0, 0.0, 1.0)

    return Intersection.new(t, point, normal, @material)
  end

  def bounding_box
    bottom = Vec3.new(@x0, @y0, @z-0.0001)
    top = Vec3.new(@x1, @y1, @z+0.0001)
    AABB.new(bottom, top)
  end
end

