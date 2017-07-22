require "./hitable_list"

module Hitable
  class CuboidWrapper < BoundedHitableList
    def initialize(p1, p2, top, bottom, front, back, left, right)
      # back | front, right | left, top | bottom
      brt = Point.new(p2.x, p2.y, p2.z)
      brb = Point.new(p2.x, p1.y, p2.z)
      blt = Point.new(p1.x, p2.y, p2.z)
      blb = Point.new(p1.x, p1.y, p2.z)
      frt = Point.new(p2.x, p2.y, p1.z)
      frb = Point.new(p2.x, p1.y, p1.z)
      flt = Point.new(p1.x, p2.y, p1.z)
      flb = Point.new(p1.x, p1.y, p1.z)

      super([
        XYRect.new(flb, frt, front).flip!,
        XYRect.new(blb, brt, back),
        XZRect.new(flb, brb, bottom).flip!,
        XZRect.new(flt, brt, top),
        YZRect.new(flb, blt, left).flip!,
        YZRect.new(frb, brt, right),
      ])
    end

    def initialize(p1, p2, mat)
      initialize(p1, p2, mat, mat, mat, mat, mat, mat)
    end
  end

  class Cuboid < BoundedHitable
    getter bot : Point
    getter top : Point
    getter center : Point

    getter material : Material

    getter area : Float64

    @bounds : Tuple(Point, Point)

    def initialize(@bot : Point, @top : Point, @material)
      @bounding_box = AABB.new(bot, top)
      @center = (@top + @bot) * 0.5
      @bounds = {@bot, @top}

      raise "bottom.x must me lower than top.x" if bot.x >= top.x
      raise "bottom.y must me lower than top.y" if bot.y >= top.y
      raise "bottom.z must me lower than top.z" if bot.z >= top.z

      @area = (top.x - bot.x) * (top.y - bot.y) + (top.x - bot.x) * (top.z - bot.z) + (top.y - bot.y) * (top.z - bot.z)
    end
    
    def hit(ray)
      # TODO: Handle cases where the ray starts inside the cube?

      tx_min = (@bounds[ray.sign[0]].x - ray.origin.x) * ray.inv_direction.x
      tx_max = (@bounds[1 - ray.sign[0]].x - ray.origin.x) * ray.inv_direction.x

      t_min = tx_min
      t_max = tx_max

      ty_min = (@bounds[ray.sign[1]].y - ray.origin.y) * ray.inv_direction.y
      ty_max = (@bounds[1 - ray.sign[1]].y - ray.origin.y) * ray.inv_direction.y

      return nil if (t_min > ty_max) || (ty_min > t_max)
      t_min = ty_min if ty_min > t_min
      t_max = ty_max if ty_max < t_max

      tz_min = (@bounds[ray.sign[2]].z - ray.origin.z) * ray.inv_direction.z
      tz_max = (@bounds[1 - ray.sign[2]].z - ray.origin.z) * ray.inv_direction.z

      return nil if (t_min > tz_max) || (tz_min > t_max)
      t_min = tz_min if tz_min > t_min
      t_max = tz_max if tz_max < t_max


      # tx_min = (@bot.x - ray.origin.x) / ray.direction.x
      # tx_max = (@top.x - ray.origin.x) / ray.direction.x
      # tx_min, tx_max = tx_max, tx_min if tx_min > tx_max

      # t_min = tx_min
      # t_max = tx_max

      # ty_min = (@bot.y - ray.origin.y) / ray.direction.y
      # ty_max = (@top.y - ray.origin.y) / ray.direction.y
      # ty_min, ty_max = ty_max, ty_min if ty_min > ty_max

      # return nil if (t_min > ty_max) || (ty_min > t_max)

      # t_min = ty_min if ty_min > t_min
      # t_max = ty_max if ty_max < t_max

      # tz_min = (@bot.z - ray.origin.z) / ray.direction.z
      # tz_max = (@top.z - ray.origin.z) / ray.direction.z
      # tz_min, tz_max = tz_max, tz_min if tz_min > tz_max

      # return nil if (t_min > tz_max) || (tz_min > t_max)

      # t_min = tz_min if tz_min > t_min
      # t_max = tz_max if tz_max < t_max

      t = t_min

      return nil if t < ray.t_min || t > ray.t_max

      point = ray.point_at_parameter(t)
      n = point - @center

      if t == tx_min
        normal = Normal.new(1.0 * sign(n.x), 0.0, 0.0)
      elsif t == ty_min
        normal = Normal.new(0.0, 1.0 * sign(n.y), 0.0)
      else
        normal = Normal.new(0.0, 0.0, 1.0 * sign(n.z))
      end

      # TODO: Calculate real u & v
      return HitRecord.new(t, point, normal, @material, self, 1.0, 1.0)
    end

    def sample
      side = rand(0..5)

      if side == 0
        {
          Point.new(
            @bot.x + rand * (@top.x - @bot.x),
            @top.y,
            @bot.z + rand * (@top.z - @bot.z)
          ),
          Normal.new(0.0, 1.0, 0.0)
        }
      elsif side == 1
        {
          Point.new(
            @bot.x + rand * (@top.x - @bot.x),
            @bot.y,
            @bot.z + rand * (@top.z - @bot.z)
          ),
          Normal.new(0.0, -1.0, 0.0)
        }
      elsif side == 2
        {
          Point.new(
            @top.x,
            @bot.y + rand * (@top.y - @bot.y),
            @bot.z + rand * (@top.z - @bot.z)
          ),
          Normal.new(1.0, 0.0, 0.0)
        }
      elsif side == 3
        {
          Point.new(
            @bot.x,
            @bot.y + rand * (@top.y - @bot.y),
            @bot.z + rand * (@top.z - @bot.z)
          ),
          Normal.new(-1.0, 0.0, 0.0)
        }
      elsif side == 4
        {
          Point.new(
            @bot.x + rand * (@top.x - @bot.x),
            @bot.y + rand * (@top.y - @bot.y),
            @top.z
          ),
          Normal.new(0.0, 0.0, 1.0)
        }
      else
        {
          Point.new(
            @bot.x + rand * (@top.x - @bot.x),
            @bot.y + rand * (@top.y - @bot.y),
            @bot.z
          ),
          Normal.new(0.0, 0.0, -1.0)
        }
      end
    end
  end
end
