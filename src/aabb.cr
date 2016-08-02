class AABB
  getter min, max

  def initialize(@min : Vec3, @max : Vec3)
  end

  def hit(ray)
    dirfrac = Vec3.new(1.0) / ray.direction

    t1 = (@min.x - ray.origin.x) * dirfrac.x
    t2 = (@max.x - ray.origin.x) * dirfrac.x
    t3 = (@min.y - ray.origin.y) * dirfrac.y
    t4 = (@max.y - ray.origin.y) * dirfrac.y
    t5 = (@min.z - ray.origin.z) * dirfrac.z
    t6 = (@max.z - ray.origin.z) * dirfrac.z

    tmin = max(max(min(t1, t2), min(t3, t4)), min(t5, t6))
    tmax = min(min(max(t1, t2), max(t3, t4)), max(t5, t6))

    return false if tmax < 0
    return false if tmin > tmax
    return true
  end

  def merge(other)
    new_min = Vec3.new(
      min(@min.x, other.min.x),
      min(@min.y, other.min.y),
      min(@min.z, other.min.z)
    )
    new_max = Vec3.new(
      max(@max.x, other.max.x),
      max(@max.y, other.max.y),
      max(@max.z, other.max.z)
    )

    AABB.new(new_min, new_max)
  end
end
