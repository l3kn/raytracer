class Hitable
  abstract class Rect < BoundedHitable
    getter bot : Point
    getter top : Point
    getter area : Float64

    def initialize(@bot : Point, @top : Point)
      @bounding_box = AABB.new(bot, top)

      # TODO: find a way to remove this
      @area = 0.0
    end

    # NOTE: (Rect.new(...).flip!) should return a Hitable, not a Normal
    def flip!
      @normal = -@normal
      self
    end
  end

  class XYRect < Rect
    def initialize(bot : Point, top : Point, @material : Material)
      raise "XYRect bot & top don't have the same z value" if bot.z != top.z
      super(bot, top)
      @normal = Normal.new(0.0, 0.0, 1.0)
      @area = (top.x - bot.x) * (top.y - bot.y)
    end

    def hit(ray)
      t = (@bot.z - ray.origin.z) * ray.inv_direction.z
      return nil if t < ray.t_min || t > ray.t_max

      point = ray.point_at_parameter(t)

      # Hitpoint is outside of the rect
      return nil if point.x < @bot.x || point.x > @top.x
      return nil if point.y < @bot.y || point.y > @top.y

      u = (point.x - @bot.x) / (@top.x - @bot.x)
      v = (point.y - @bot.y) / (@top.y - @bot.y)
      return HitRecord.new(t, point, @normal, @material, self, u, v)
    end

    def sample
      {
        Point.new(
          @bot.x + rand * (@top.x - @bot.x),
          @bot.y + rand * (@top.y - @bot.y),
          @bot.z
        ),
        @normal,
      }
    end
  end

  class XZRect < Rect
    def initialize(bot : Point, top : Point, @material : Material)
      raise "XZRect bot & top don't have the same y value" if bot.y != top.y
      super(bot, top)
      @normal = Normal.new(0.0, 1.0, 0.0)
      @area = (top.x - bot.x) * (top.z - bot.z)
    end

    def hit(ray)
      t = (@bot.y - ray.origin.y) * ray.inv_direction.y
      return nil if t < ray.t_min || t > ray.t_max

      point = ray.point_at_parameter(t)

      # Hitpoint is outside of the rect
      return nil if point.x < @bot.x || point.x > @top.x
      return nil if point.z < @bot.z || point.z > @top.z

      u = (point.x - @bot.x) / (@top.x - @bot.x)
      v = (point.z - @bot.z) / (@top.z - @bot.z)
      return HitRecord.new(t, point, @normal, @material, self, u, v)
    end

    def sample
      {
        Point.new(
          @bot.x + rand * (@top.x - @bot.x),
          @bot.y,
          @bot.z + rand * (@top.z - @bot.z)
        ),
        @normal,
      }
    end
  end

  class YZRect < Rect
    def initialize(bot : Point, top : Point, @material : Material)
      raise "YZRect bot & top don't have the same x value" if bot.x != top.x
      super(bot, top)
      @normal = Normal.new(1.0, 0.0, 0.0)
      @area = (top.y - bot.y) * (top.z - bot.z)
    end

    def hit(ray)
      t = (@bot.x - ray.origin.x) * ray.inv_direction.x
      return nil if t < ray.t_min || t > ray.t_max

      point = ray.point_at_parameter(t)

      # Hitpoint is outside of the rect
      return nil if point.y < @bot.y || point.y > @top.y
      return nil if point.z < @bot.z || point.z > @top.z

      u = (point.z - @bot.z) / (@top.z - @bot.z)
      v = (point.y - @bot.y) / (@top.y - @bot.y)
      return HitRecord.new(t, point, @normal, @material, self, u, v)
    end

    def sample
      {
        Point.new(
          @bot.x,
          @bot.y + rand * (@top.y - @bot.y),
          @bot.z + rand * (@top.z - @bot.z)
        ),
        @normal,
      }
    end
  end
end
