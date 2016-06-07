class Lambertian < Material
  property texture

  def initialize(@texture : Texture)
  end

  def scatter(ray, hit)
    target = hit.normal + random_in_unit_sphere

    ray_new = Ray.new(hit.point, target)
    Scattered.new(ray_new, @texture.value(hit.point, hit.u, hit.v))
  end
end
