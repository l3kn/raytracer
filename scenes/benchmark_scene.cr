require "../raytracer"

hitables = [] of Hitable

hitables << TransformationWrapper.new(
  Hitable::Sphere.new(Material::Mirror.new(Color.new(0.8))),
  VS.new(Vector.new(0.0, -100.5, -1.0), 100.0)
)

hitables << TransformationWrapper.new(
  Hitable::Sphere.new(Material::Mirror.new(Color.new(0.8, 0.6, 0.2))),
  VS.new(Vector.new(1.0, 0.0, -1.0), 0.5)
)

hitables << TransformationWrapper.new(
  Hitable::Sphere.new(Material::Matte.new(Color.new(0.1, 0.2, 0.5))),
  VS.new(Vector.new(0.0, 0.0, -1.0), 0.5)
)

hitables << TransformationWrapper.new(
  Hitable::Sphere.new(Material::Glass.new(1.8, Color::WHITE, Color::WHITE)),
  VS.new(Vector.new(-1.0, 0.0, -1.0), 0.5)
)

dimensions = {800, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(-1.5, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 30.0,
  dimensions: dimensions
)

raytracer = Raytracer::Simple.new(
  dimensions, camera,
  scene: Scene.new(hitables, background: Background::Sky.new),
  samples: 100
)

raytracer.render("benchmark.png")
