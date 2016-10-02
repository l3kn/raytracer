require "./vector"

struct AABB
  getter min : Point
  getter max : Point

  def initialize(min, max)
    @min = min.min(max)
    @max = min.max(max)
  end

  def fast_hit(ray : ExtendedRay)
    x1 = (@min.x - ray.origin.x) * ray.inv_x
    x2 = (@max.x - ray.origin.x) * ray.inv_x
    y1 = (@min.y - ray.origin.y) * ray.inv_y
    y2 = (@max.y - ray.origin.y) * ray.inv_y
    z1 = (@min.z - ray.origin.z) * ray.inv_z
    z2 = (@max.z - ray.origin.z) * ray.inv_z

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
    Point.new(
      @min.x * 0.5 + @max.x * 0.5,
      @min.y * 0.5 + @max.y * 0.5,
      @min.z * 0.5 + @max.z * 0.5,
    )
  end

  def bounding_sphere
    center = centroid
    BoundingSphere.new(center, center.distance(@max))
  end

  def self.from_points(points : Array(Point))
    min = points[0]
    max = points[0]

    points[1..-1].each do |point|
      min = min.min(point)
      max = max.max(point)
    end

    self.new(min, max)
  end
end

struct BoundingSphere
  getter center : Point
  getter radius : Float64

  def initialize(@center, @radius)
  end
end
