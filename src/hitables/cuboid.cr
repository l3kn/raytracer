class Cuboid < FiniteHitableList
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
