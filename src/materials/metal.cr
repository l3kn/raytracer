require "../material"
require "../texture"

class Metal < Material
  property texture, fuzz

  def initialize(color : Color, @fuzz = 0.0)
    @texture = ConstantTexture.new(color)
  end

  def initialize(@texture : Texture, @fuzz = 0.0)
  end

  def scatter(ray, hit)
    reflected = ray.direction.normalize.reflect(hit.normal)

    ScatterRecord.new(
      @texture.value(hit),
      Ray.new(hit.point, reflected + random_in_unit_sphere*@fuzz, ray.t_min, ray.t_max)
    )
  end
end
