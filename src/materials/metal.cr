require "../texture"

class Metal < Material
  property texture, fuzz
  def initialize(@texture : Texture, @fuzz = 0.0)
  end

  def scatter(ray, hit)
    reflected = ray.direction.normalize.reflect(hit.normal)
    ray_new = Ray.new(hit.point, reflected + random_in_unit_sphere*@fuzz)

    if ray_new.direction.dot(hit.normal) > 0
      Scattered.new(ray_new, @texture.value(hit.point, hit.u, hit.v))
    else
      nil
    end
  end
end
