class PixelTexture < Texture
  getter pixels : Array(Array(Vec3))
  getter width : Int32 
  getter height : Int32 

  def initialize(@pixels)
    @width = @pixels.first.size
    @height = @pixels.size
  end

  def value(point, u, v)
    x = u * (@width - 1)
    y = v * (@height - 1)

    @pixels[y.to_i][x.to_i]
  end

  def save(filename)
    ppm = PPM.new(width, height, filename)

    @pixels.each do |line|
      line.each do |pixel|
        ppm.add(pixel)
      end
    end

    ppm.close
  end
end

class MinecraftTextures
  def self.load
    textures = [] of PixelTexture

    # Format: 16x16 grid of 24px square textures 
    raw_lines = File.read("minecraft/minecraft.ppm").lines

    # Parse body
    # Result (simplified, 2x2 textures "a" to "f")
    #   [
    #    a1, a2, b1, b2, c1, c2,
    #    a3, a4, b3, b4, c3, c4,
    #    d1, d2, e1, e2, f1, f2,
    #    d3, d4, e3, e4, f3, f4
    #   ]
    
    # Read all values into a long list of ints
    raw = raw_lines[3..-1].map { |line| line.split.map(&.to_i) }.flatten
    
    # Create vec3 from each rgb triple
    raw = raw.each_slice(3).map { |rgb| Vec3.new(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0) }

    # Restore the original "line" length of 256 pixels
    raw = raw.each_slice(256)

    size_x = 16
    size_y = 16

    # Split into size_y high rows of values
    #  [
    #   [a1, a2, b1, b2, c1, c2]
    #   [a3, a4, b3, b4, c3, c4]
    #  ],
    #  [
    #   [d1, d2, e1, e2, f1, f2]
    #   [d3, d4, e3, e4, f3, f4]
    #  ]
    rows = raw.each_slice(size_y)

    rows.each do |row|
      # Split each rows "subrows / lines" into chunks of size_x
      #  [
      #   [[a1, a2], [b1, b2], [c1, c2]]
      #   [[a3, a4], [b3, b4], [c3, c4]]
      #  ]
      raw_textures = row.map { |r| r.each_slice(size_x).to_a }

      # Transpose / swap rows (!= rows above)
      # and cols in the texture matrix
      #  [
      #   [[a1, a2], [a3, a4]],
      #   [[b1, b2], [b3, b4]],
      #   [[c1, c2], [c3, c4]]
      #  ]
      raw_textures = raw_textures.transpose

      raw_textures.each do |raw_texture|
        textures << PixelTexture.new(raw_texture)
      end
    end

    textures
  end
end
