class Metal < Material
  property texture, fuzz
  def initialize(@texture, @fuzz = 0.0)
  end

  def scatter(ray, hit)
    reflected = ray.direction.normalize.reflect(hit.normal)
    scattered = Ray.new(hit.point, reflected + random_in_unit_sphere*@fuzz)

    if scattered.direction.dot(hit.normal) > 0
      {scattered, @texture.value(hit.point)}
    else
      nil
    end
  end
end
