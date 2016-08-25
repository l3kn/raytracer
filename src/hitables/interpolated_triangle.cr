class InterpolatedTriangle < Hitable
  getter bounding_box
  # Vertices
  getter a : Vec3
  getter b : Vec3
  getter c : Vec3
  # Vertex normals
  getter na : Vec3
  getter nb : Vec3
  getter nc : Vec3
  property material : Material

  getter edge1 : Vec3
  getter edge2 : Vec3

  def initialize(@a, @b, @c, @na, @nb, @nc, @material)
    min = Vec3.new(
      [@a.x, @b.x, @c.x].min,
      [@a.y, @b.y, @c.y].min,
      [@a.z, @b.z, @c.z].min
    )

    max = Vec3.new(
      [@a.x, @b.x, @c.x].max,
      [@a.y, @b.y, @c.y].max,
      [@a.z, @b.z, @c.z].max
    )

    @bounding_box = AABB.new(min, max)

    @edge1 = @b - @a
    @edge2 = @c - @a
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
      bc = barycentricCoordinates(point)
      normal = @na * bc.x + @nb * bc.y + @nc * bc.z
      return HitRecord.new(t, point, normal, @material, u, v)
    else
      return nil
    end
  end

  def barycentricCoordinates(p)
    v0 = @b - @a
    v1 = @c - @a
    v2 = p - @a

    d00 = v0.dot(v0)
    d01 = v0.dot(v1)
    d11 = v1.dot(v1)
    d20 = v2.dot(v0)
    d21 = v2.dot(v1)

    denom = d00 * d11 - d01 * d01

    v = (d11 * d20 - d01 * d21) / denom
    w = (d00 * d21 - d01 * d20) / denom
    u = 1.0 - v - w

    Vec3.new(u, v, w)
  end
end

