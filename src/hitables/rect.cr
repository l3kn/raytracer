class XYRect < Hitable
  property x0 : Float64, x1 : Float64, y0 : Float64, y1 : Float64, z : Float64, material

  def initialize(bottom : Vec3, top : Vec3, @material : Material)
    if bottom.z != top.z
      raise "XYRect bottom & top don't have the same z value"
    end

    @x0 = bottom.x
    @x1 = top.x
    @y0 = bottom.y
    @y1 = top.y
    @z = bottom.z

    @normal = Vec3.new(0.0, 0.0, 1.0)
  end

  def flip!
    @normal = -@normal
  end

  def hit(ray, t_min, t_max)
    t = (@z - ray.origin.z) / ray.direction.z
    return nil if t < t_min || t > t_max

    point = ray.point_at_parameter(t)

    # Hitpoint is outside of the rect
    return nil if point.x < @x0 || point.x > @x1 ||
                  point.y < @y0 || point.y > @y1

    u = (point.x - @x0) / (@x1 - @x0) 
    v = (point.y - @y0) / (@y1 - @y0) 
    return Intersection.new(t, point, @normal, @material, u, v)
  end

  def bounding_box
    bottom = Vec3.new(@x0, @y0, @z-0.0001)
    top = Vec3.new(@x1, @y1, @z+0.0001)
    AABB.new(bottom, top)
  end
end

class XZRect < Hitable
  property x0 : Float64, x1 : Float64, y : Float64, z0 : Float64, z1 : Float64, material

  def initialize(bottom : Vec3, top : Vec3, @material : Material)
    if bottom.y != top.y
      raise "XZRect bottom & top don't have the same y value"
    end

    @x0 = bottom.x
    @x1 = top.x
    @y = bottom.y
    @z0 = bottom.z
    @z1 = top.z

    @normal = Vec3.new(0.0, 1.0, 0.0)
  end

  def flip!
    @normal = -@normal
  end

  def hit(ray, t_min, t_max)
    t = (@y - ray.origin.y) / ray.direction.y
    return nil if t < t_min || t > t_max

    point = ray.point_at_parameter(t)

    # Hitpoint is outside of the rect
    return nil if point.x < @x0 || point.x > @x1 ||
                  point.z < @z0 || point.z > @z1

    u = (point.x - @x0) / (@x1 - @x0) 
    v = (point.z - @z0) / (@z1 - @z0) 
    return Intersection.new(t, point, @normal, @material, u, v)
  end

  def bounding_box
    bottom = Vec3.new(@x0, @y-0.0001, @z0)
    top = Vec3.new(@x1, @y+0.0001, @z1)
    AABB.new(bottom, top)
  end
end

class YZRect < Hitable
  property x : Float64, y0 : Float64, y1 : Float64, z0 : Float64, z1 : Float64, material

  def initialize(bottom : Vec3, top : Vec3, @material : Material)
    if bottom.x != top.x
      raise "YZRect bottom & top don't have the same x value"
    end

    @x = bottom.x
    @y0 = bottom.y
    @y1 = top.y
    @z0 = bottom.z
    @z1 = top.z

    @normal = Vec3.new(1.0, 0.0, 0.0)
  end

  def flip!
    @normal = -@normal
  end

  def hit(ray, t_min, t_max)
    t = (@x - ray.origin.x) / ray.direction.x
    return nil if t < t_min || t > t_max

    point = ray.point_at_parameter(t)

    # Hitpoint is outside of the rect
    return nil if point.y < @y0 || point.y > @y1 ||
                  point.z < @z0 || point.z > @z1

    u = (point.z - @z0) / (@z1 - @z0) 
    v = (point.y - @y0) / (@y1 - @y0) 
    return Intersection.new(t, point, @normal, @material, u, v)
  end

  def bounding_box
    bottom = Vec3.new(@x-0.0001, @y0, @z0)
    top = Vec3.new(@x+0.0001, @y1, @z1)
    AABB.new(bottom, top)
  end
end
