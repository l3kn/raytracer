require "../src/raytracer"
require "../src/backgrounds/*"

mat = Lambertian.new(Vec3.from_hex("#EFC94C"))

hitables = [] of Hitable

obj = File.read("models/monkey.obj")

vertices = [] of Vec3

obj.lines.each do |line|
  tokens = line.split
  next if tokens.empty?

  case tokens[0]
  when "v"
    cords = tokens[1, 3].map(&.to_f)
    vertices << Vec3.new(cords[0], cords[1], cords[2])
  when "f"
    if tokens.size == 4
      a, b, c = tokens[1, 3].map { |i| vertices[i.split("//")[0].to_i - 1] }
      hitables << Triangle.new(a, b, c, mat)
    elsif tokens.size == 5
      a, b, c, d = tokens[1, 4].map { |i| vertices[i.split("//")[0].to_i - 1] }
      hitables << Triangle.new(a, b, c, mat)
      hitables << Triangle.new(a, c, d, mat)
    else
      raise "To many points in polygon"
    end

    # na, nb, nc = tokens[1, 3].map { |i| normals[i.split("//")[1].to_i - 1] }
    # hitables << InterpolatedTriangle.new(a, b, c, na, nb, nc, mat)
  end
end

puts "Parsed #{vertices.size} vertices"
puts "Parsed #{vertices.size} normals"
puts "Parsed #{hitables.size} faces"

width, height = {400, 400}
# width, height = {200, 200}

camera = Camera.new(
  look_from: Vec3.new(1.0, -0.45, 4.0),
  look_at: Vec3.new(1.0, -0.6, 0.4),
  up: Vec3::Y,
  vertical_fov: 40,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.0
)

hitables << XYRect.new(
  Vec3.new(-10.0, -10.0, -1.0),
  Vec3.new(10.0, 10.0, -1.0),
  Lambertian.new(Vec3.from_hex("#334D5C"))
)

light1 = Sphere.new(
  Vec3.new(0.5, 1.0, 3.0),
  1.0,
  DiffuseLight.new(Vec3.new(4.0))
)

light2 = Sphere.new(
  Vec3.new(1.5, 1.0, 3.0),
  1.0,
  DiffuseLight.new(Vec3.new(4.0))
)

hitables << light1
hitables << light2

raytracer = Raytracer.new(width, height,
                          hitables: BVHNode.new(hitables),
                          focus_hitables: HitableList.new([light1, light2]),
                          camera: camera,
                          samples: 20,
                          # background: CubeMap.new("cube_maps/Yokohama"))
                          # background: SkyBackground.new)l
                          background: ConstantBackground.new(Vec3.new(0.0, 0.0, 0.0)))
raytracer.recursion_depth = 2
raytracer.gamma_correction = 1.0/1.4

raytracer.render("monkey.png")
