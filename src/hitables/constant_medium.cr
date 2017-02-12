require "../hitable"

class ConstantMedium < FiniteHitable
  property object : FiniteHitable
  property density : Float64
  property material : Material

  def initialize(@object, @density, texture)
    @material = Lambertian.new(texture)
    @bounding_box = @object.bounding_box
  end

  def hit(ray)
    if (hit1 = object.hit(ray))
      if (hit2 = object.hit(Ray.new(ray.origin, ray.direction, hit1.t + EPSILON, Float64::MAX)))
        t1 = hit1.t
        t2 = hit2.t
        t1 = ray.t_min if t1 < ray.t_min
        t2 = ray.t_max if t2 > ray.t_max

        return nil if t1 >= t2
        t1 = 0 if t1 < 0

        distance_inside_boundary = (t2 - t1) * ray.direction.length
        hit_distance = -(1 / @density) * Math.log(pos_random)

        if (hit_distance < distance_inside_boundary)
          t = t1 + hit_distance / ray.direction.length
          return HitRecord.new(
            t: t ,
            point: ray.point_at_parameter(t),
            normal: (-ray.direction).to_normal,
            material: @material,
            u: 0.0, v: 0.0
          )
        end
      end
    end
    nil
  end
end
