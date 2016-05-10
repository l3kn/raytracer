require "../texture"

class Metal < Material
  property texture, fuzz
  def initialize(@texture : Texture, @fuzz = 0.0)
  end

  def scatter(ray, hit)
    reflected = ray.direction.normalize.reflect(hit.normal)
    scattered = Ray.new(hit.point, reflected + random_in_unit_sphere*@fuzz)

    if scattered.direction.dot(hit.normal) > 0
      {scattered, @texture.value(hit.point, hit.u, hit.v)}
    else
      nil
    end
  end
end
