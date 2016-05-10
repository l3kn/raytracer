class DiffuseLight < Material
  property texture

  def initialize(@texture : Texture)
  end

  def emitted(hit)
    @texture.value(hit.point, hit.u, hit.v)
  end
end
