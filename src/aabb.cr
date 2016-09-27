require "./vector"

struct AABB
  getter min : Point
  getter max : Point

  def initialize(min, max)
    @min = min.min(max)
    @max = min.max(max)
  end

  def hit(ray)
    dirfrac = Vector::ONE / ray.direction

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

  def merge(other : AABB)
    AABB.new(
      @min.min(other.min),
      @max.max(other.max)
    )
  end

  def centroid
    @min * 0.5 + @max * 0.5
  end

  def bounding_sphere
    center = centroid
    BoundingSphere.new(center, center.distance(@max))
  end
end

struct BoundingSphere
  getter center : Point
  getter radius : Float64

  def initialize(@center, @radius)
  end
end
