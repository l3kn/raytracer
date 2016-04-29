abstract class Texture
  abstract def value(point)
end

class ConstantTexture < Texture
  def initialize(@color)
  end

  def value(point)
    @color
  end
end

class CheckerTexture < Texture
  def initialize(@even : Texture, @odd : Texture)
  end

  def value(point)
    sines = Math.sin(10*point.x)*Math.sin(10*point.y)*Math.sin(10*point.z)
    if sines < 0
      @odd.value(point)
    else
      @even.value(point)
    end
  end
end
