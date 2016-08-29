require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"

mat = Lambertian.new(Vec3.from_hex("#FFD700"))
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

width, height = {400, 400}

camera = Camera.new(
  look_from: Vec3.new(-1.5, 1.5, -2.0),
  look_at: Vec3.new(0.0, 0.5, 0.0),
  up: Vec3::Y,
  vertical_fov: 40,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.0
)

raytracer = SimpleRaytracer.new(width, height,
                                hitables: BVHNode.new(hitables),
                                camera: camera,
                                samples: 100,
                                background: CubeMap.new("cube_maps/Yokohama"))
                                # background: SkyBackground.new)
                                # background: ConstantBackground.new(Vec3.new(1.0, 0.0, 0.0)))

raytracer.render("teapot1.png")
