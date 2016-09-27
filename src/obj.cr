module OBJ
  def self.parse(filename, mat, interpolated = false, textured = false, materials = {} of String => Material)
    obj = File.read(filename)

    hitables = [] of FiniteHitable
    vertices = [] of Point
    normals = [] of Normal
    texture_coords = [] of Vector

    material = mat

    obj.lines.each do |line|
      tokens = line.split
      next if tokens.empty?

      case tokens[0]
      when "usemtl"
        name = tokens[1]
        if materials.has_key?(name)
          material = materials[name]
        else
          puts "Error, Missing material #{name}"
          material = mat
        end
      when "v"
        cords = tokens[1, 3].map(&.to_f)
        vertices << Point.new(cords[0], cords[1], cords[2])
      when "vn"
        cords = tokens[1, 3].map(&.to_f)
        # normals << Normal.new(cords[0], cords[1], cords[2])
        normals << Vector.new(cords[0], cords[1], cords[2]).to_normal
      when "vt"
        cords = tokens[1, 3].map(&.to_f)
        texture_coords << Vector.new(cords[0], cords[1], cords[2])
      when "f"
        vs = tokens[1..-1].map { |i| i.split("/") }

        (1..(vs.size - 2)).each do |i|
          a = vertices[vs[0][0].to_i - 1]
          b = vertices[vs[i][0].to_i - 1]
          c = vertices[vs[i + 1][0].to_i - 1]

          if interpolated
            raise "Error, there are no normals in this .obj file" if normals.empty?

            na = normals[vs[0][2].to_i - 1]
            nb = normals[vs[i][2].to_i - 1]
            nc = normals[vs[i + 1][2].to_i - 1]
            if textured
              raise "Error, there are no texture coords in this .obj file" if materials.empty?
              ta = texture_coords[vs[0][1].to_i - 1]
              tb = texture_coords[vs[i][1].to_i - 1]
              tc = texture_coords[vs[i + 1][1].to_i - 1]

              hitables << TexturedTriangle.new(a, b, c, na, nb, nc, ta, tb, tc, material)
            else
              hitables << InterpolatedTriangle.new(a, b, c, na, nb, nc, mat)
            end
          else
            hitables << Triangle.new(a, b, c, mat)
          end
        end
      end
    end
    puts "Parsed #{vertices.size} vertices"
    puts "Parsed #{vertices.size} normals"
    puts "Parsed #{texture_coords.size} texture coords"
    puts "Parsed #{hitables.size} faces"

    hitables
  end
end
