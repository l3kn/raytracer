class Hitable
  module Rect
    # Helper function to create the correct subtype of rectangle
    # depending on the input values
    def self.new(bot, top, material, flipped = false)
      if bot.x == top.x
        YZRect.new(bot, top, material, flipped)
      elsif bot.y == top.y
        XZRect.new(bot, top, material, flipped)
      elsif bot.z == top.z
        XYRect.new(bot, top, material, flipped)
      else
        raise "bot & top must have the same value in some component"
      end
    end
  end

  class XYRect < BoundedHitable
    @area : Float64

    def initialize(@bot : Point, @top : Point, @material : Material, flipped = false)
      raise "XYRect bot & top don't have the same z value" if bot.z != top.z
      @normal = Normal.new(0.0, 0.0, flipped ? -1.0 : 1.0)
      @area = (top.x - bot.x) * (top.y - bot.y)
      @bounding_box = AABB.new(bot, top)
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

  class XZRect < BoundedHitable
    @area : Float64

    def initialize(@bot : Point, @top : Point, @material : Material, flipped = false)
      raise "XZRect bot & top don't have the same y value" if bot.y != top.y
      @normal = Normal.new(0.0, flipped ? -1.0 : 1.0, 0.0)
      @area = (top.x - bot.x) * (top.z - bot.z)
      @bounding_box = AABB.new(bot, top)
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

  class YZRect < BoundedHitable
    @area : Float64
    
    def initialize(@bot : Point, @top : Point, @material : Material, flipped = false)
      raise "YZRect bot & top don't have the same x value" if bot.x != top.x
      @normal = Normal.new(flipped ? -1.0 : 1.0, 0.0, 0.0)
      @area = (top.y - bot.y) * (top.z - bot.z)
      @bounding_box = AABB.new(bot, top)
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
