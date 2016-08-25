require "../src/raytracer"
require "../src/backgrounds/*"

mat = Lambertian.new(Vec3.from_hex("#FFD700"))

world = [] of Hitable

obj = File.read("models/teapot.obj")

vertices = [] of Vec3
normals = [] of Vec3

obj.lines.each do |line|
  tokens = line.split

  case tokens[0]
  when "v"
    cords = tokens[1, 3].map(&.to_f)
    vertices << Vec3.new(cords[0], cords[1], cords[2])
  when "vn"
    cords = tokens[1, 3].map(&.to_f)
    normals << Vec3.new(cords[0], cords[1], cords[2])
  when "f"
    a, b, c = tokens[1, 3].map { |i| vertices[i.split("//")[0].to_i - 1] }
    na, nb, nc = tokens[1, 3].map { |i| normals[i.split("//")[1].to_i - 1] }
    world << InterpolatedTriangle.new(a, b, c, na, nb, nc, mat)
  end
end

puts "Parsed #{vertices.size} vertices"
puts "Parsed #{vertices.size} normals"
puts "Parsed #{world.size} faces"

width, height = {400, 400}

# Camera params
look_from = Vec3.new(-1.5, 1.5, -2.0)
look_at = Vec3.new(0.0, 0.5, 0.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 40

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.001

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                world: BVHNode.new(world),
                                camera: camera,
                                samples: 100,
                                background: CubeMap.new("cube_maps/Yokohama"))
                                # background: SkyBackground.new)
                                # background: ConstantBackground.new(Vec3.new(1.0, 0.0, 0.0)))

raytracer.render("teapot1.png")
