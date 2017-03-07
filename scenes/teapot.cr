require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/obj"

# mat = MatteMaterial.new(Color.from_hex("#FFD700"))
mat = OrenNayarMaterial.new(Color.from_hex("#FFD700"), 20.0)
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

width, height = {400, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(-1.5, 1.5, -2.0),
  look_at: Point.new(0.0, 0.5, 0.0),
  vertical_fov: 40.0,
  dimensions: {width, height}
)

scene = Scene.new(
  hitables.map(&.as(Hitable)),
  [
    PointLight.new(Point.new(-1.5, 1.5, -1.0),
      Color.new(10.0)).as(Light),
  ],
  ConstantBackground.new(Color::BLACK) # SkyBackground.new

)

raytracer = WhittedRaytracer.new(
  width, height,
  scene: scene,
  camera: camera,
  samples: 2
)

raytracer.recursion_depth = 1

raytracer.render("teapot1.png")
