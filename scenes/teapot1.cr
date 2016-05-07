require "../simple_raytracer"

ct1 = ConstantTexture.new(Vec3.new(0.8))
ct2 = ConstantTexture.new(Vec3.new(0.1, 0.2, 0.5))
ct3 = ConstantTexture.new(Vec3.new(0.8, 0.6, 0.2))
mat = Lambertian.new(ct2)

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
    t1 = Triangle.new(a, b, c, mat)
    t2 = Triangle.new(a, c, b, mat)

    na, nb, nc = tokens[1, 3].map { |i| normals[i.split("//")[1].to_i - 1] }
    vnormal = ((na + nb + nc) / 3.0).normalize

    d1 = (t1.normal - vnormal).length
    d2 = (t2.normal - vnormal).length

    if d1 < d2
      world << t1
    else
      world << t2
    end
  end
end

puts "Parsed #{vertices.size} vertices"
puts "Parsed #{vertices.size} normals"
puts "Parsed #{world.size} faces"

width, height = {800, 400}

# Camera params
look_from = Vec3.new(-1.5, 1.5, 2.5)
look_at = Vec3.new(0.0, 0.0, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 30

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.001

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                # world: HitableList.new(world),
                                world: HitableList.new(world),
                                camera: camera,
                                samples: 50)

raytracer.render("teapot1.ppm")
