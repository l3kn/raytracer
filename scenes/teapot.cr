require "../raytracer"

mat = Material::Mirror.new(Color.from_hex("#FFD700"))
hitables = OBJ.parse("models/teapot.obj", mat, interpolated: true)

dimensions = {400, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(-1.5, 1.5, -2.0),
  look_at: Point.new(0.0, 0.5, 0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

raytracer = Raytracer::Simple.new(
  dimensions,
  scene: Scene.new(
    hitables.map(&.as(Hitable)),
    background: Background::Sky.new
  ),
  camera: camera,
  samples: 50
)

raytracer.render("teapot1.png")
