record Intersection,
  t : Float64,
  point : Vec3,
  normal : Vec3,
  material : Material

abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (Intersection | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box.min.xyz[n]
  end
end

