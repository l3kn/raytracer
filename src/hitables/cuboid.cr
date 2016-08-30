require "../hitable"
require "./hitable_list"

class Cuboid < Hitable
  getter list : HitableList
  def initialize(p1, p2, top, bottom, front, back, left, right)
    # back | front, right | left, top | bottom
    brt = Vec3.new(p2.x, p2.y, p2.z)
    brb = Vec3.new(p2.x, p1.y, p2.z)
    blt = Vec3.new(p1.x, p2.y, p2.z)
    blb = Vec3.new(p1.x, p1.y, p2.z)
    frt = Vec3.new(p2.x, p2.y, p1.z)
    frb = Vec3.new(p2.x, p1.y, p1.z)
    flt = Vec3.new(p1.x, p2.y, p1.z)
    flb = Vec3.new(p1.x, p1.y, p1.z)

    rect_front  = XYRect.new(flb, frt, front)
    rect_back   = XYRect.new(blb, brt, back)

    rect_left   = YZRect.new(flb, blt, left)
    rect_right  = YZRect.new(frb, brt, right)

    rect_bottom = XZRect.new(flb, brb, bottom)
    rect_top    = XZRect.new(flt, brt, top)

    rect_front.flip!
    rect_left.flip!
    rect_bottom.flip!

    @list = HitableList.new([rect_front, rect_back,
                             rect_left, rect_right,
                             rect_bottom, rect_top])
  end


  def initialize(p1, p2, mat)
    # Use the same material for all 6 sides
    initialize(p1, p2, mat, mat, mat, mat, mat, mat)
  end

  def hit(ray, t_min, t_max)
    @list.hit(ray, t_min, t_max)
  end

  def bounding_box
    @list.bounding_box
  end
end
