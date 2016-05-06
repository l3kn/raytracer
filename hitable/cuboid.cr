require "../hitable"

class Cuboid < Hitable
  def initialize(p1, p2, material)
    # back | front, right | left, top | bottom
    brt = Vec3.new(p2.x, p2.y, p2.z)
    brb = Vec3.new(p2.x, p1.y, p2.z)
    blt = Vec3.new(p1.x, p2.y, p2.z)
    blb = Vec3.new(p1.x, p1.y, p2.z)
    frt = Vec3.new(p2.x, p2.y, p1.z)
    frb = Vec3.new(p2.x, p1.y, p1.z)
    flt = Vec3.new(p1.x, p2.y, p1.z)
    flb = Vec3.new(p1.x, p1.y, p1.z)

    front  = XYRect.new(flb, frt, material)
    back   = XYRect.new(blb, brt, material)

    left   = YZRect.new(flb, blt, material)
    right  = YZRect.new(frb, brt, material)

    bottom = XZRect.new(flb, brb, material)
    top    = XZRect.new(flt, brt, material)

    front.flip!
    left.flip!
    bottom.flip!

    @list = HitableList.new([front, back, left, right, bottom, top])
  end

  def hit(ray, t_min, t_max)
    @list.hit(ray, t_min, t_max)
  end

  def bounding_box
    @list.bounding_box
  end
end
