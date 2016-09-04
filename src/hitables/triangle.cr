require "../hitable"

class Triangle < Hitable
  getter bounding_box : AABB
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
      u, v = get_uv(ray, point, u, v)
      normal = get_normal(ray, point, u, v)
      return HitRecord.new(t, point, normal, @material, u, v)
    else
      return nil
    end
  end

  def get_normal(ray, point, u, v)
    if @normal.dot(ray.direction) < 0.0
      @normal
    else
      -@normal
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

    Vec3.new(u, v, w)
  end
end

class InterpolatedTriangle < Triangle
  # Vertex normals
  getter na : Vec3
  getter nb : Vec3
  getter nc : Vec3

  def initialize(@a, @b, @c, @na, @nb, @nc, @material)
    super(@a, @b, @c, @material)
  end

  def get_normal(ray, point, u, v)
    bc = barycentric_coordinates(point)
    @na * bc.x + @nb * bc.y + @nc * bc.z
  end
end

class TexturedTriangle < InterpolatedTriangle
  # Texture coordinates
  getter ta : Vec3
  getter tb : Vec3
  getter tc : Vec3

  def initialize(@a, @b, @c, @na, @nb, @nc, @ta, @tb, @tc, @material)
    super(@a, @b, @c, @na, @nb, @nc, @material)
  end

  def get_uv(ray, point, u, v)
    bc = barycentric_coordinates(point)
    texture_coords = @ta * bc.x + @tb * bc.y + @tc * bc.z
    texture_coords.xy
  end
end
