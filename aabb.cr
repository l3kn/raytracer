class AABB
  getter min, max

  def initialize(@min, @max)
  end

  def hit(ray, tmin, tmax)
    min_ = @min.xyz
    max_ = @max.xyz

    origin = ray.origin.xyz
    dir = ray.direction.xyz

    (0...3).each do |a|
      t0, t1 = minmax(min_[a] - origin[a] / dir[a],
                      max_[a] - origin[a] / dir[a])

      tmin = max(t0, tmin)
      tmax = min(t1, tmax)

      return false if tmax <= tmin
    end
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
