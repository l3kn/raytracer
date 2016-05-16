require "./ppm"

class CubeMap
  getter right    : PPM
  getter left     : PPM
  getter up       : PPM
  getter down     : PPM
  getter forward  : PPM
  getter backward : PPM

  def initialize(name)
    @right    = PPM.load("#{name}/posx.ppm")
    @left     = PPM.load("#{name}/negx.ppm")
    @up       = PPM.load("#{name}/posy.ppm")
    @down     = PPM.load("#{name}/negy.ppm")
    @forward  = PPM.load("#{name}/posz.ppm")
    @backward = PPM.load("#{name}/negz.ppm")
  end

  def read(ray)
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

    texture.get(i, j)
  end
end
