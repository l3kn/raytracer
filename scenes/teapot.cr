require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"

mat = Lambertian.new(Color.from_hex("#FFD700"))
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

width, height = {400, 400}

camera = Camera.new(
  look_from: Point.new(-1.5, 1.5, -2.0),
  look_at: Point.new(0.0, 0.5, 0.0),
  vertical_fov: 40,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = SimpleRaytracer.new(width, height,
  hitables: BVHNode.new(hitables),
  camera: camera,
  samples: 10,
  # background: CubeMap.new("cube_maps/Yokohama"))
  background: SkyBackground.new)

raytracer.render("teapot1.png")
