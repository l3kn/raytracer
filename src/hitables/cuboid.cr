require "../hitable"
require "./hitable_list"

class Cuboid < FiniteHitable
  getter list : FiniteHitableList

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

    rect_front = XYRect.new(flb, frt, front)
    rect_back = XYRect.new(blb, brt, back)

    rect_left = YZRect.new(flb, blt, left)
    rect_right = YZRect.new(frb, brt, right)

    rect_bottom = XZRect.new(flb, brb, bottom)
    rect_top = XZRect.new(flt, brt, top)

    rect_front.flip!
    rect_left.flip!
    rect_bottom.flip!

    @list = FiniteHitableList.new([rect_front, rect_back,
      rect_left, rect_right,
      rect_bottom, rect_top])
    @bounding_box = AABB.new(p1, p2)
  end

  def initialize(p1, p2, mat)
    # Use the same material for all 6 sides
    initialize(p1, p2, mat, mat, mat, mat, mat, mat)
  end

  def hit(ray)
    @list.hit(ray)
  end

  def pdf_value(origin, direction)
    @list.pdf_value(origin, direction)
  end

  def random(origin)
    @list.random(origin)
  end
end
