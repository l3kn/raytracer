require "../raytracer"

hitables = [] of Hitable
lights = [] of Light

hitables << TransformationWrapper.new(
  Sphere.new(MirrorMaterial.new(Color.new(0.8))),
  VS.new(Vector.new(0.0, -100.5, -1.0), 100.0)
)

hitables << TransformationWrapper.new(
  Sphere.new(MirrorMaterial.new(Color.new(0.8, 0.6, 0.2))),
  VS.new(Vector.new(1.0, 0.0, -1.0), 0.5)
)

hitables << TransformationWrapper.new(
  Sphere.new(MatteMaterial.new(Color.new(0.1, 0.2, 0.5))),
  VS.new(Vector.new(0.0, 0.0, -1.0), 0.5)
)

hitables << TransformationWrapper.new(
  Sphere.new(GlassMaterial.new(Color::WHITE, Color::WHITE, 1.8)),
  VS.new(Vector.new(-1.0, 0.0, -1.0), 0.5)
)

dimensions = {800, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(-1.5, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 30.0,
  dimensions: dimensions
)

raytracer = SimpleRaytracer.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights, SkyBackground.new),
  samples: 100
)

raytracer.render("benchmark.png")
