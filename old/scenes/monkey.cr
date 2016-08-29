require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"

mat = Lambertian.new(Vec3.from_hex("#EFC94C"))
hitables = OBJ.parse("models/monkey.obj", mat)

# width, height = {1920, 1080}
width, height = {400, 400}

camera = Camera.new(
  look_from: Vec3.new(1.0, -0.45, 4.0),
  look_at: Vec3.new(1.0, -0.6, 0.4),
  up: Vec3::Y,
  vertical_fov: 40,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.0
)

wall = XYRect.new(
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

# hitables << light1
# hitables << light2

raytracer = Raytracer.new(width, height,
                          hitables: HitableList.new([BVHNode.new(hitables), wall, light1, light2]),
                          focus_hitables: HitableList.new([light1, light2]),
                          camera: camera,
                          samples: 300,
                          # background: CubeMap.new("cube_maps/Yokohama"))
                          # background: SkyBackground.new)l
                          background: ConstantBackground.new(Vec3.new(0.0, 0.0, 0.0)))
raytracer.recursion_depth = 2
raytracer.gamma_correction = 1.0/1.4

raytracer.render("monkey.png")
