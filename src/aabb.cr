require "./vector"

# __AABB = Axis-Aligned Bounding Boxes__
# 
# An `AABB` is defined by two points, `@min` and `@max`,
# and is part of every `BoundedHitable`.
# There it is used when constructing `Hitable::BVHNode`s
struct AABB
  getter min : Point, max : Point

  # Create a new AABB from two points.
  # There is no need to check if `min < max`.
  def initialize(min, max)
    @min = min.min(max)
    @max = min.max(max)
  end

  # Create an empty AABB.
  # `@min` will be the largest possible point
  # while `@max` will be the smallest possible one.
  # This way the result of merging with another box
  # is always equal to the other box
  def initialize
    @min = Point.new(Float64::MAX)
    @max = Point.new(-Float64::MAX)
  end

  # Check if a Ray intersects the AABB.
  # This only returns `true` or `false`,
  # not a `HitRecord`.
  def fast_hit(ray : Ray)
    if ray.sign[0] == 0
      min = (@min.x - ray.origin.x) * ray.inv_direction.x
      max = (@max.x - ray.origin.x) * ray.inv_direction.x
    else
      max = (@min.x - ray.origin.x) * ray.inv_direction.x
      min = (@max.x - ray.origin.x) * ray.inv_direction.x
    end

    if ray.sign[1] == 0
      y_min = (@min.y - ray.origin.y) * ray.inv_direction.y
      y_max = (@max.y - ray.origin.y) * ray.inv_direction.y
    else
      y_max = (@min.y - ray.origin.y) * ray.inv_direction.y
      y_min = (@max.y - ray.origin.y) * ray.inv_direction.y
    end

    return false if min > y_max || y_min > max
    min = y_min if y_min > min
    max = y_max if y_max < max

    if ray.sign[2] == 0
      z_min = (@min.z - ray.origin.z) * ray.inv_direction.z
      z_max = (@max.z - ray.origin.z) * ray.inv_direction.z
    else
      z_max = (@min.z - ray.origin.z) * ray.inv_direction.z
      z_min = (@max.z - ray.origin.z) * ray.inv_direction.z
    end

    return false if min > z_max || z_min > max
    min = z_min if z_min > min
    max = z_max if z_max < max

    # TODO: check against t_min and t_max
    # tmin = max(max(x_min, y_min), z_min)
    # tmax = min(min(x_max, y_max), z_max)

    max > 0 && min <= max
  end

  # Create a new AABB that wraps this and the other AABB
  def merge(other : AABB)
    AABB.new(@min.min(other.min), @max.max(other.max))
  end

  # Create a new AABB that wraps this one and the some `Point`
  def merge(other : Point)
    AABB.new(@min.min(other), @max.max(other))
  end

  # Center point of the AABB
  def centroid
    (@min + @max) / 2.0
  end

  # Vector from `@min` to `@max`
  def diagonal : Vector
    @max - @min
  end

  # Relative position of a point inside the AABB.
  # The result is a `Point` ranging from
  # `(0, 0, 0)` to `(1, 1, 1)`.
  def offset(point : Point) : Point
    extent = diagonal
    offset = point - @min
    Point.new(offset.x / extent.x, offset.y / extent.y, offset.z / extent.z)
  end

  # Surface area
  def area : Float64
    delta = diagonal
    (delta.x * delta.y + delta.x * delta.z + delta.y * delta.z) * 2.0
  end

  # Create an AABB wraping a list of points
  def self.from_points(points : Array(Point))
    min = Point.new(Float64::MAX)
    max = Point.new(-Float64::MAX)

    points.each do |point|
      min = min.min(point)
      max = max.max(point)
    end

    self.new(min, max)
  end

  # Create a AABB around some point
  def self.around(point : Point, radius : Float64)
    self.new(
      Point.new(point.x - radius, point.y - radius, point.z - radius),
      Point.new(point.x + radius, point.y + radius, point.z + radius)
    )
  end
end
