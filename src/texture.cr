require "./perlin"

abstract class Texture
  abstract def value(point : Point, normal : Normal, u : Float64, v : Float64) : Color
end

abstract class Texture1D
  abstract def value(point : Point, normal : Normal, u : Float64, v : Float64) : Float64
end

class NormalTexture < Texture
  def value(point, normal, u, v)
    Color.new(
      (1.0 + normal.x) * 0.5,
      (1.0 + normal.y) * 0.5,
      (1.0 + normal.z) * 0.5,
    )
  end
end

class ConstantTexture < Texture
  def initialize(@color : Color); end
  def value(point, normal, u, v); @color; end
end

class CheckerTexture < Texture
  def initialize(@even : Texture, @odd : Texture); end

  # TODO: Use uv values instead
  def value(point, normal, u, v)
    sines = Math.sin(10*point.x)*Math.sin(10*point.y)*Math.sin(10*point.z)
    if sines < 0
      @odd.value(point, normal, u, v)
    else
      @even.value(point, normal, u, v)
    end
  end
end

class NoiseTexture1D < Texture1D
  def initialize(@scale = 10.0, @noise = Perlin.new(100)); end

  def value(point, normal, u, v)
    @noise.perlin(point * @scale)
  end
end

class NoiseTexture < Texture
  def initialize(scale = 10.0)
    @tex1D = NoiseTexture1D.new(scale)
  end

  def value(point, normal, u, v)
    Color.new(@tex1D.value(point, normal, u, v))
  end
end

class ImageTexture < Texture
  getter canvas : StumpyPNG::Canvas

  def initialize(path)
    @canvas = StumpyPNG.read(path)
  end

  def value(point, normal, u, v)
    x = (1 - (u % 1.0)) * (@canvas.width - 1)
    y = (1 - (v % 1.0)) * (@canvas.height - 1)

    color = @canvas[x.to_i, y.to_i]
    Color.new(
      color.r.to_f / UInt16::MAX,
      color.g.to_f / UInt16::MAX,
      color.b.to_f / UInt16::MAX
    )
  end
end

class UTexture < Texture
  def initialize(@factor = 1.0); end

  def value(point, normal, u, v)
    Color.new((1 - u) ** @factor)
  end
end
