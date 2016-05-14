require "./vec3"

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

  def self.read(filename)
    lines = File.read(filename).lines.map(&.chomp)

    type = lines[0]
    dimensions = lines[1].split.map(&.to_i) 
    depth = lines[2]

    raise "Invalid ppm file format #{type}" unless type == "P3"
    raise "Invalid ppm depth #{depth}" unless depth == "255" # TODO: Support depths other than 255

    # Convert file into one long list of integers
    raw_body = lines[3..-1].map { |line| line.split.map(&.to_i) }.flatten

    # Create color vectors from each integer triple (r, g, b)
    raw = raw_body.each_slice(3).map { |rgb| Vec3.new(rgb[0] / 255.0, rgb[1] / 255.0, rgb[2] / 255.0) }

    # "Restore" the original width
    raw.each_slice(dimensions[0]).to_a
  end
end
