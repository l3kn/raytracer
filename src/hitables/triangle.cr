class Triangle < Hitable
  getter bounding_box
  getter a : Vec3
  getter b : Vec3
  getter c : Vec3
  property material : Material

  getter edge1 : Vec3
  getter edge2 : Vec3
  getter normal : Vec3

  def initialize(@a, @b, @c, @material)
    min = @a.min(@b).min(@c)
    max = @a.max(@b).max(@c)

    @bounding_box = AABB.new(min, max)

    @edge1 = @b - @a
    @edge2 = @c - @a

    @normal = edge1.cross(edge2).normalize
  end

  EPSILON = 0.000001

  # Möller-Trumbore intersection algorithm
  def hit(ray, t_min, t_max)
    p = ray.direction.cross(@edge2)
    det = @edge1.dot(p)

    # Ray lies in the plane of the triangle
    return nil if det > -EPSILON && det < EPSILON

    inv_det = 1.0 / det

    t = ray.origin - @a
    u = t.dot(p) * inv_det

    # The intersection lies outside of the triangle
    return nil if u < 0.0 || u > 1.0

    q = t.cross(@edge1)
    v = ray.direction.dot(q) * inv_det

    # The intersection lies outside of the triangle
    return nil if v < 0.0 || (u + v) > 1.0

    t = @edge2.dot(q) * inv_det

    if (t < t_max && t > t_min)
      point = ray.point_at_parameter(t)
      if @normal.dot(ray.direction) < 0.0
        return HitRecord.new(t, point, @normal, @material, u, v)
      else
        return HitRecord.new(t, point, -@normal, @material, u, v)
      end
    else
      return nil
    end
  end
end

