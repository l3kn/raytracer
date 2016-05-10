class PPM
  def initialize(width, height, filename)
    @file = File.open(filename, "w")

    # Write ppm header
    @file.puts "P3"
    @file.puts "#{width} #{height}"
    @file.puts "255"
  end

  def close
    @file.close
  end

  def add(color) 
    color *= 255

    # Make sure color values are valid (0..255)
    rgb = color.xyz.map { |v| min(max(v.to_i, 0), 255) }
    @file.puts rgb.join(" ")
  end
end
