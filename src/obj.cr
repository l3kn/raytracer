module OBJ
  def self.parse(filename, mat, interpolated = false)
    obj = File.read(filename)

    hitables = [] of Hitable
    vertices = [] of Vec3
    normals  = [] of Vec3

    obj.lines.each do |line|
      tokens = line.split
      next if tokens.empty?

      case tokens[0]
      when "v"
        cords = tokens[1, 3].map(&.to_f)
        vertices << Vec3.new(cords[0], cords[1], cords[2])
      when "vn"
        cords = tokens[1, 3].map(&.to_f)
        normals << Vec3.new(cords[0], cords[1], cords[2])
      when "f"
        vs = tokens[1..-1].map { |i| i.split("/") }

        (1..(vs.size - 2)).each do |i|
          a = vertices[vs[  0][0].to_i - 1]
          b = vertices[vs[  i][0].to_i - 1]
          c = vertices[vs[i+1][0].to_i - 1]

          unless interpolated
            hitables << Triangle.new(a, b, c, mat)
          else
            raise "Error, there are no normals in this .obj file" if normals.empty?

            na = normals[vs[  0][2].to_i - 1]
            nb = normals[vs[  i][2].to_i - 1]
            nc = normals[vs[i+1][2].to_i - 1]
            hitables << InterpolatedTriangle.new(a, b, c, na, nb, nc, mat)
          end
        end
      end
    end
    puts "Parsed #{vertices.size} vertices"
    puts "Parsed #{vertices.size} normals"
    puts "Parsed #{hitables.size} faces"

    hitables
  end
end
