class AABB
  getter min, max

  def initialize(@min : Vec3, @max : Vec3)
    # if @min.z == @max.z
      # @min = Vec3.new(@min.xy, @min.z - 0.01)
      # @max = Vec3.new(@max.xy, @max.z + 0.01)
    # end
  end

  def hit(ray)
    dirfrac = Vec3::ONE / ray.direction

    x1 = (@min.x - ray.origin.x) * dirfrac.x
    x2 = (@max.x - ray.origin.x) * dirfrac.x
    y1 = (@min.y - ray.origin.y) * dirfrac.y
    y2 = (@max.y - ray.origin.y) * dirfrac.y
    z1 = (@min.z - ray.origin.z) * dirfrac.z
    z2 = (@max.z - ray.origin.z) * dirfrac.z

    tmin = max(max(min(x1, x2), min(y1, y2)), min(z1, z2))
    tmax = min(min(max(x1, x2), max(y1, y2)), max(z1, z2))

    tmax > 0 && tmin <= tmax
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

  def centroid
    @min * 0.5 + @max * 0.5
  end
end
