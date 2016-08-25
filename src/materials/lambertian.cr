require "../onb"
require "../material"

class Lambertian < Material
  property texture

  def initialize(color : Vec3)
    @texture = ConstantTexture.new(color)
  end

  def initialize(@texture : Texture)
  end

  def scatter(ray, hit)
    ScatterRecord.new(
      @texture.value(hit.point, hit.u, hit.v),
      CosinePDF.new(hit.normal)
    )
  end

  def scattering_pdf(ray_in, hit, scattered)
    cosine = hit.normal.dot(scattered.direction.normalize)

    if cosine < 0
      0.0
    else
      cosine / Math::PI
    end
  end
end
