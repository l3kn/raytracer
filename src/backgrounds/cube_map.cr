class Background
  # Use cube maps as a backgound.
  # See [Wikipedia](https://en.wikipedia.org/wiki/Cube_mapping)
  # for an explanation of how this works.
  class CubeMap < Background
    @right : StumpyPNG::Canvas
    @left  : StumpyPNG::Canvas
    @up    : StumpyPNG::Canvas
    @down  : StumpyPNG::Canvas
    @front : StumpyPNG::Canvas
    @back  : StumpyPNG::Canvas

    # `name` should point to a folder
    # containing six images
    # `posx.png`, `negx.png`,
    # `posy.png`, `negy.png`,
    # `posz.png`, `negz.png`
    # for the right, left, top, bottom, front
    # and back of the cube
    def initialize(name)
      @right = StumpyPNG.read("#{name}/posx.png")
      @left  = StumpyPNG.read("#{name}/negx.png")
      @up    = StumpyPNG.read("#{name}/posy.png")
      @down  = StumpyPNG.read("#{name}/negy.png")
      @front = StumpyPNG.read("#{name}/posz.png")
      @back  = StumpyPNG.read("#{name}/negz.png")
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
          read_texture(@front, u, v)
        else
          u = (dir.x / dir.z + 1.0) / 2
          v = (dir.y / dir.z + 1.0) / 2
          read_texture(@back, u, v)
        end
      end
    end

    private def read_texture(texture, u, v)
      i = (u * texture.width).to_i
      j = (v * texture.height).to_i
      Color.from_rgba(texture.get(i, j))
    end
  end
end
