class DiffuseLight < Material
  property texture

  def initialize(@texture : Texture)
  end

  def emitted(point)
    texture.value(point)
  end
end
