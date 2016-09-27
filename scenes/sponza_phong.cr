require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"
require "../src/phong/*"

module MTL
  def self.parse(filename)
    materials = {} of String => Material
    last = Phong::Material.new(Color::BLACK, Color::BLACK, Color::BLACK, 0.0, ConstantTexture.new(Color::WHITE))

    File.each_line(filename) do |line|
      tokens = line.chomp.gsub("\t", "").split(" ")
      # p tokens
      next if tokens.size == 0

      case tokens.first
      when "newmtl"
        last = Phong::Material.new(Color::BLACK, Color::BLACK, Color::BLACK, 0.0, ConstantTexture.new(Color::WHITE))
        materials[tokens[1]] = last
      when "Ka"
        values = tokens[1, 3].map(&.to_f)
        last.k_a = Color.new(values[0], values[1], values[2])
      when "Kd"
        values = tokens[1, 3].map(&.to_f)
        last.k_d = Color.new(values[0], values[1], values[2])
      when "Ks"
        values = tokens[1, 3].map(&.to_f)
        last.k_s = Color.new(values[0], values[1], values[2])
      when "map_Kd"
        name = tokens[1].gsub("\\", "/")
        texture_filename = "old/models/sponza/#{name}"

        if File.exists?(texture_filename)
          last.texture = ImageTexture.new(texture_filename)
        end
      when "Ns"
        last.shininess = tokens[1].to_f
      end
    end

    materials
  end
end

mat = Lambertian.new(Color.new(0.0, 0.0, 1.0))
materials = MTL.parse("old/models/sponza/sponza.mtl")
hitables = OBJ.parse("old/models/sponza/sponza.obj", mat, interpolated: true, textured: true, materials: materials)

# width, height = {1920, 1080}
width, height = 400, 400
node = SAHBVHNode.new(hitables)

camera = Camera.new(
  look_from: Point.new(940.0, 600.0, 80.0),
  look_at: Point.new(0.0, 400.0, 0.0),
  vertical_fov: 70,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = Phong::Raytracer.new(width, height,
                                 hitables: node,
                                 lights: [Phong::Light.new(Point.new(0.0, 1000.0, 0.0), 1.0)],
                                 ambient: 0.05,
                                 camera: camera,
                                 samples: 5,
                                 background: ConstantBackground.new(Color.new(1.0)))
raytracer.render("sponza_phong.png")
