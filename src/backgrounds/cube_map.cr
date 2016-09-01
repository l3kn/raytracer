require "stumpy_png"
require "../vec3"
require "../background"

class CubeMap < Background
  getter right    : StumpyPNG::Canvas
  getter left     : StumpyPNG::Canvas
  getter up       : StumpyPNG::Canvas
  getter down     : StumpyPNG::Canvas
  getter forward  : StumpyPNG::Canvas
  getter backward : StumpyPNG::Canvas

  def initialize(name)
    @right    = StumpyPNG.read("#{name}/posx.png")
    @left     = StumpyPNG.read("#{name}/negx.png")
    @up       = StumpyPNG.read("#{name}/posy.png")
    @down     = StumpyPNG.read("#{name}/negy.png")
    @forward  = StumpyPNG.read("#{name}/posz.png")
    @backward = StumpyPNG.read("#{name}/negz.png")
  end

  def get(ray)
    dir = ray.direction

    if dir.x.abs >= dir.y.abs && dir.x.abs >= dir.z.abs
      if dir.x >= 0.0
        u = 1.0 - (dir.z / dir.x + 1.0) / 2
        v = 1.0 - (dir.y / dir.x + 1.0) / 2
        read_texture(@right, u, v)
      else
        u = (dir.z / dir.x + 1.0) / 2
        v = (dir.y / dir.x + 1.0) / 2
        read_texture(@left, u, v)
      end
    elsif dir.y.abs >= dir.x.abs && dir.y.abs >= dir.z.abs
      if dir.y >= 0.0
        u = (dir.x / dir.y + 1.0) / 2
        v = (dir.z / dir.y + 1.0) / 2
        read_texture(@up, u, v)
      else
        u = 1.0 - (dir.x / dir.y + 1.0) / 2
        v = 1.0 - (dir.z / dir.y + 1.0) / 2
        read_texture(@down, u, v)
      end
    else
      if dir.z >= 0.0
        u = (dir.x / dir.z + 1.0) / 2
        v = 1.0 - (dir.y / dir.z + 1.0) / 2
        read_texture(@forward, u, v)
      else
        u = (dir.x / dir.z + 1.0) / 2
        v = (dir.y / dir.z + 1.0) / 2
        read_texture(@backward, u, v)
      end
    end
  end

  def read_texture(texture, u, v)
    i = (u * texture.width).to_i
    j = (v * texture.height).to_i

    max = UInt16::MAX
    pixel = texture[i, j]

    Vec3.new(
      pixel.r.to_f / max,
      pixel.g.to_f / max,
      pixel.b.to_f / max,
    )
  end
end
