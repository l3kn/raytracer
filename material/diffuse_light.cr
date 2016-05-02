class DiffuseLight < Material
  property texture

  def initialize(@texture)
  end

  def emitted(point)
    texture.value(point)
  end
end
