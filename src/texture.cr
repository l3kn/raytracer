require "./perlin"

abstract class Texture
  abstract def value(hit : HitRecord) : Color
end

abstract class Texture1D
  abstract def value(hit : HitRecord) : Float64
end

class NormalTexture < Texture
  def value(hit)
    Color.new(
      (1.0 + hit.normal.x) * 0.5,
      (1.0 + hit.normal.y) * 0.5,
      (1.0 + hit.normal.z) * 0.5,
    )
  end
end

class ConstantTexture < Texture
  def initialize(@color : Color); end
  def value(hit); @color; end
end

class CheckerTexture < Texture
  def initialize(@even : Texture, @odd : Texture); end

  # TODO: Use uv values instead
  def value(hit)
    point = hit.point
    sines = Math.sin(10*point.x)*Math.sin(10*point.y)*Math.sin(10*point.z)
    if sines < 0
      @odd.value(hit)
    else
      @even.value(hit)
    end
  end
end

class NoiseTexture1D < Texture1D
  def initialize(@scale = 10.0, @noise = Perlin.new(100)); end

  def value(hit)
    @noise.perlin(hit.point * @scale)
  end
end

class NoiseTexture < Texture
  def initialize(scale = 10.0)
    @tex1D = NoiseTexture1D.new(scale)
  end

  def value(hit)
    Color.new(@tex1D.value(hit))
  end
end

class ImageTexture < Texture
  getter canvas : StumpyPNG::Canvas

  def initialize(path)
    @canvas = StumpyPNG.read(path)
  end

  def value(hit)
    x = (1 - (hit.u % 1.0)) * (@canvas.width - 1)
    y = (1 - (hit.v % 1.0)) * (@canvas.height - 1)

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

  def value(hit)
    Color.new((1 - hit.u) ** @factor)
  end
end
