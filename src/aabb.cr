require "./vector"

struct AABB
  getter min : Point, max : Point

  def initialize(min, max)
    @min = min.min(max)
    @max = min.max(max)
  end

  def initialize
    @min = Point.new(Float64::MAX)
    @max = Point.new(-Float64::MAX)
  end

  def fast_hit(ray : ExtendedRay)
    if ray.pos_x
      min = (@min.x - ray.origin.x) * ray.inv_x
      max = (@max.x - ray.origin.x) * ray.inv_x
    else
      max = (@min.x - ray.origin.x) * ray.inv_x
      min = (@max.x - ray.origin.x) * ray.inv_x
    end

    if ray.pos_y
      y_min = (@min.y - ray.origin.y) * ray.inv_y
      y_max = (@max.y - ray.origin.y) * ray.inv_y
    else
      y_max = (@min.y - ray.origin.y) * ray.inv_y
      y_min = (@max.y - ray.origin.y) * ray.inv_y
    end

    return false if min > y_max || y_min > max
    min = y_min if y_min > min
    max = y_max if y_max < max

    if ray.pos_z
      z_min = (@min.z - ray.origin.z) * ray.inv_z
      z_max = (@max.z - ray.origin.z) * ray.inv_z
    else
      z_max = (@min.z - ray.origin.z) * ray.inv_z
      z_min = (@max.z - ray.origin.z) * ray.inv_z
    end

    return false if min > z_max || z_min > max
    min = z_min if z_min > min
    max = z_max if z_max < max

    # TODO: check against t_min and t_max
    # tmin = max(max(x_min, y_min), z_min)
    # tmax = min(min(x_max, y_max), z_max)

    max > 0 && min <= max
  end

  def merge(other : AABB)
    AABB.new(@min.min(other.min), @max.max(other.max))
  end

  def merge(other : Point)
    AABB.new(@min.min(other), @max.max(other))
  end

  def centroid
    (@min + @max) / 2.0
  end

  def diagonal : Vector
    @max - @min
  end

  def offset(point : Point) : Point
    extent = diagonal
    offset = point - @min
    Point.new(offset.x / extent.x, offset.y / extent.y, offset.z / extent.z)
  end

  def area : Float64
    delta = diagonal
    (delta.x * delta.y + delta.x * delta.z + delta.y * delta.z) * 2.0
  end

  def self.from_points(points : Array(Point))
    min = max = points[0]

    points[1..-1].each do |point|
      min = min.min(point)
      max = max.max(point)
    end

    self.new(min, max)
  end

  def self.around(point : Point, radius : Float64)
    self.new(
      Point.new(point.x - radius, point.y - radius, point.z - radius),
      Point.new(point.x + radius, point.y + radius, point.z + radius)
    )
  end
end
