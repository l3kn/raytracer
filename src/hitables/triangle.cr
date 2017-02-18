require "../hitable"

class Triangle < FiniteHitable
  getter a : Point
  getter b : Point
  getter c : Point
  property material : Material

  getter edge1 : Vector
  getter edge2 : Vector
  getter normal : Normal

  def initialize(@a, @b, @c, @material)
    min = @a.min(@b).min(@c)
    max = @a.max(@b).max(@c)

    @bounding_box = AABB.new(min, max)

    @edge1 = @b - @a
    @edge2 = @c - @a

    @normal = edge1.cross(edge2).to_normal
  end

  # Möller-Trumbore intersection algorithm
  def hit(ray)
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

    if (t < ray.t_max && t > ray.t_min)
      point = ray.point_at_parameter(t)
      u, v = get_uv(ray, point, u, v)
      normal = get_normal(ray, point, u, v)
      return HitRecord.new(t, point, normal, @material, self, u, v)
    else
      return nil
    end
  end

  def get_normal(ray, point, u, v)
    if @normal.dot(ray.direction) < 0.0
      @normal
    else
      @normal.flip
    end
  end

  def get_uv(ray, point, u, v)
    {u, v}
  end

  def barycentric_coordinates(p)
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

    Point.new(u, v, w)
  end
end

class InterpolatedTriangle < Triangle
  # Vertex normals
  getter na : Normal
  getter nb : Normal
  getter nc : Normal

  def initialize(@a, @b, @c, @na, @nb, @nc, @material)
    super(@a, @b, @c, @material)
  end

  def get_normal(ray, point, u, v)
    bc = barycentric_coordinates(point)
    Vector.new(
      @na.x * bc.x + @nb.x * bc.y + @nc.x * bc.z,
      @na.y * bc.x + @nb.y * bc.y + @nc.y * bc.z,
      @na.z * bc.x + @nb.z * bc.y + @nc.z * bc.z,
    ).to_normal
  end
end

class TexturedTriangle < InterpolatedTriangle
  # Texture coordinates
  getter ta : Vector
  getter tb : Vector
  getter tc : Vector

  def initialize(@a, @b, @c, @na, @nb, @nc, @ta, @tb, @tc, @material)
    super(@a, @b, @c, @na, @nb, @nc, @material)
  end

  def get_uv(ray, point, u, v)
    bc = barycentric_coordinates(point)
    texture_coords = @ta * bc.x + @tb * bc.y + @tc * bc.z
    texture_coords.xy
  end
end
