require "./perlin"

abstract class Texture
  abstract def value(point, u, v)
end

class TextureConverter
  def self.from_json(json)
    type = "constant"
    color = Vec3.new(0.0)

    json.read_object do |key|
      case key
      when "type"
        type = json.read_string
      when "color"
        color = Vec3.new(json)
      end
    end

    puts type
    return ConstantTexture.new(color)
  end

  def self.to_json(value, io)
  end
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
