struct Intersection
  getter t : Float64
  getter point : Vec3
  getter normal : Vec3
  getter material : Material

  def initialize(@t, @point, @normal, @material)
  end
end

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box.min.xyz[n]
  end
end

