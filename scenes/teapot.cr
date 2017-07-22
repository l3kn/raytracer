require "../raytracer"

mat = MirrorMaterial.new(Color.from_hex("#FFD700"))
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

dimensions = {400, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(-1.5, 1.5, -2.0),
  look_at: Point.new(0.0, 0.5, 0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

scene = Scene.new(
  hitables.map(&.as(UnboundedHitable)),
  [] of Light,
  SkyBackground.new()
)

raytracer = Renderer::Simple.new(
  dimensions,
  scene: scene,
  camera: camera,
  samples: 50
)

raytracer.render("teapot1.png")
