require "../material"
require "../texture"

class DiffuseLight < Material
  property texture
  property intensity

  def initialize(color : Vec3, @intensity = 1.0)
    @texture = ConstantTexture.new(color)
  end

  def initialize(@texture : Texture, @intensity = 1.0)
  end

  def emitted(ray, hit)
    # Only emit light on one side
    if hit.normal.dot(ray.direction) < 0.0
      @texture.value(hit.point, hit.u, hit.v) * @intensity
    else
      Vec3::ZERO
    end
  end
end
