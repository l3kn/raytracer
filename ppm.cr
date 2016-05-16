require "./vec3"

class PPM
  getter width : Int32
  getter height : Int32
  getter buffer : Array(Array(Vec3))

  def initialize(@width, @height, @buffer = [] of Array(Vec3))
    @height.times do |i|
      row = [] of Vec3
      @width.times do |j|
        row << Vec3.new
      end
      @buffer << row
    end
  end

  def save(filename)
    file = File.open(filename, "w")

    # Write ppm header
    file.puts "P3"
    file.puts "#{@width} #{@height}"
    file.puts "255"

    @buffer.reverse_each do |row|
      row.each do |color|
        color *= 255
        # Make sure color values are valid (0..255)
        rgb = color.xyz.map { |v| min(max(v.to_i, 0), 255) }
        file.puts rgb.join(" ")
      end
    end

    file.close
  end

  def set(x, y, color) 
    @buffer[y][x] = color
  end

  def get(x, y)
    @buffer[y][x]
  end

  def self.load(filename)
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
    PPM.new(dimensions[0], dimensions[1], raw.each_slice(dimensions[0]).to_a)
  end
end
