class Lambertian < Material
  property texture

  def initialize(@texture)
  end

  def scatter(ray, hit)
    target = hit.point + hit.normal + random_in_unit_sphere

    scattered = Ray.new(hit.point, target - hit.point)
    {scattered, @texture.value(hit.point)}
  end
end
