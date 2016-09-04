require "stumpy_png"
require "./perlin"

abstract class Texture
  abstract def value(point, u, v)
end

class ConstantTexture < Texture
  def initialize(@color : Vec3)
  end

  def value(point, u, v)
    @color
  end
end

class CheckerTexture < Texture
  def initialize(@even : Texture, @odd : Texture)
  end

  # TODO: Use uv values instead
  def value(point, u, v)
    sines = Math.sin(10*point.x)*Math.sin(10*point.y)*Math.sin(10*point.z)
    if sines < 0
      @odd.value(point, u, v)
    else
      @even.value(point, u, v)
    end
  end
end

class NoiseTexture < Texture
  def initialize(@scale = 1)
    @noise = Perlin.new(100)
  end

  def value(point, u, v)
    Vec3.new(@noise.perlin(point * @scale))
  end
end

class ImageTexture < Texture
  getter canvas : StumpyPNG::Canvas

  def initialize(path)
    @canvas = StumpyPNG.read(path)
  end

  def value(point, u, v)
    x = (1 - (u % 1.0)) * (@canvas.width - 1)
    y = (1 - (v % 1.0)) * (@canvas.height - 1)

    color = @canvas[x.to_i, y.to_i]
    Vec3.new(
      color.r.to_f / UInt16::MAX,
      color.g.to_f / UInt16::MAX,
      color.b.to_f / UInt16::MAX
    )
  end
end
