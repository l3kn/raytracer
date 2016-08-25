require "./material"

record HitRecord,
  t : Float64, # Ray parameter of the hitpoint
  point : Vec3,
  normal : Vec3,
  material : Material,
  u : Float64, # Vars for texture mapping
  v : Float64


abstract class Hitable
  abstract def hit(ray : Ray, t_min : Float, t_max : Float) : (HitRecord | Nil)
  abstract def bounding_box

  def box_min_on_axis(n)
    bounding_box.min.xyz[n]
  end

  def pdf_value(origin, direction)
    raise "Error, this feature is not supported yet"
  end

  def random(origin)
    raise "Error, this feature is not supported yet"
  end
end

