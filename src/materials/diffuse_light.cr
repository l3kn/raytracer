require "../material"
require "../texture"

class DiffuseLight < Material
  property texture

  def initialize(color : Vec3)
    @texture = ConstantTexture.new(color)
  end

  def initialize(@texture : Texture)
  end

  def emitted(ray, hit)
    # Only emit light on one side
    if hit.normal.dot(ray.direction) < 0.0
      @texture.value(hit.point, hit.u, hit.v)
    else
      Vec3.new(0.0, 0.0, 0.0)
    end
  end
end
