require "../material"

class Dielectric < Material
  property reflection_index

  def initialize(@reflection_index : Float64)
  end

  def scatter(ray, hit)
    dir = ray.direction
    reflected = dir.reflect(hit.normal)

    dir_normal = dir.dot(hit.normal)

    if dir_normal > 0
      outward_normal = hit.normal.flip
      ni_over_nt = @reflection_index
      cosine = dir_normal / ray.direction.length
      cosine = Math.sqrt(1 - (reflection_index**2)*(1 - cosine**2))
    else
      outward_normal = hit.normal
      ni_over_nt = 1.0 / @reflection_index
      cosine = -dir_normal / ray.direction.length
    end

    refracted = ray.direction.refract(outward_normal, ni_over_nt)

    if refracted
      reflect_prob = schlick(cosine, @reflection_index)
    else
      return ScatterRecord.new(Color::WHITE, Ray.new(hit.point, reflected, ray.t_min, ray.t_max))
    end

    if rand < reflect_prob
      ray_new = Ray.new(hit.point, reflected, ray.t_min, ray.t_max)
    else
      ray_new = Ray.new(hit.point, refracted, ray.t_min, ray.t_max)
    end

    ScatterRecord.new(Color::WHITE, ray_new)
  end
end
