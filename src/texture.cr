require "stumpy_png"
require "./perlin"

abstract class Texture
  abstract def value(hit : HitRecord) : Color
end

class Texture::Normal < Texture
  def value(hit)
    Color.new(
      (1.0 + hit.normal.x) * 0.5,
      (1.0 + hit.normal.y) * 0.5,
      (1.0 + hit.normal.z) * 0.5,
    )
  end
end

class Texture::Constant < Texture
  def initialize(@color : Color); end

  def value(hit)
    @color
  end
end

class Texture::Checker < Texture
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

class Texture::Noise < Texture
  def initialize(@scale = 10.0, @noise = Perlin.new(100))
  end

  def value(hit)
    Color.new(@noise.perlin(hit.point * @scale))
  end
end

class Texture::Image < Texture
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

class Texture::U < Texture
  def initialize(@factor = 1.0); end

  def value(hit)
    Color.new((1 - hit.u) ** @factor)
  end
end

class Texture::Grid < Texture
  @step : Float64
  @substep : Float64
  @width : Float64

  def initialize(@step, @substep, @width)
  end

  def value(hit)
    # height = hit.point.y / @step
    x = hit.point.x / @step
    z = hit.point.z / @step
    x_ = hit.point.x / @substep
    z_ = hit.point.z / @substep

    if x % 1.0 < @width || z % 1.0 < @width
      Color::BLACK
    elsif x_ % 1.0 < @width || z_ % 1.0 < @width
      Color::BLACK * 0.5
    else
      Color.new(
        (1.0 + hit.normal.x) * 0.5,
        (1.0 + hit.normal.y) * 0.5,
        (1.0 + hit.normal.z) * 0.5,
      )
    end
  end
end
