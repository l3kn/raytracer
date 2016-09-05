require "../hitable"

class ConstantMedium < Hitable
  property object : Hitable
  property density : Float64
  property material : Material

  def initialize(@object, @density, texture)
    @material = Lambertian.new(texture)
  end

  def hit(ray, t_min, t_max)
    if (hit1 = object.hit(ray, -Float64::MAX, Float64::MAX))
      if (hit2 = object.hit(ray, hit1.t + 0.0001, Float64::MAX))
        t1 = hit1.t
        t2 = hit2.t
        t1 = t_min if t1 < t_min
        t2 = t_max if t2 > t_max

        return nil if t1 >= t2
        t1 = 0 if t1 < 0

        distance_inside_boundary = (t2 - t1) * ray.direction.length
        hit_distance = -(1 / @density) * Math.log(pos_random)

        if (hit_distance < distance_inside_boundary)
          t = t1 + hit_distance / ray.direction.length
          return HitRecord.new(
            t: t ,
            point: ray.point_at_parameter(t),
            normal: -ray.direction.normalize,
            material: @material,
            u: 0.0, v: 0.0
          )
        end
      end
    end
    nil
  end

  def bounding_box
    @object.bounding_box
  end
end
