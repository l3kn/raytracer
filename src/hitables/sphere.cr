require "../hitable"

module Hitable
  class Sphere < BoundedHitable
    property material
    getter area : Float64

    def initialize(@material : Material)
      @bounding_box = AABB.new(Point.new(-1.0), Point.new(1.0))
      @area = FOURPI
    end

    def hit(ray)
      # NOTE: The sphere is always centered at (0, 0, 0) and has a radius of 1.0
      ts = solve_quadratic(
        ray.direction.squared_length,
        2.0 * ray.origin.dot(ray.direction),
        ray.origin.squared_length - 1.0
      )
      return nil if ts.nil?

      t0, t1 = ts
      return nil if t0 > ray.t_max || t1 < ray.t_min

      t_hit = t0
      if t0 < ray.t_min
        t_hit = t1
        return nil if t_hit > ray.t_max
      end

      point = ray.point_at_parameter(t_hit)

      # This only works bc/ radius = 1.0
      normal = Normal.new(point.x, point.y, point.z)

      u = 0.5 + Math.atan2(-normal.z, -normal.x) * INV_TWOPI
      v = 0.5 - Math.asin(-normal.y) * INV_PI

      return HitRecord.new(t_hit, point, normal, @material, self, u, v)
    end

    def sample : {Point, Normal}
      # NOTE: Constructing the normal by hand is a little bit faster
      point_s = Point.new(rand, rand, rand).normalize
      {point_s, Normal.new(point_s.x, point_s.y, point_s.z)}
    end
  end
end
