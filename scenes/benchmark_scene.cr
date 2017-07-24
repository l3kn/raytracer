require "../raytracer"

hitables = [] of Hitable

hitables << Hitable::Sphere.new(Material::Mirror.new(Color.new(0.8)))
  .translate(Vector.new(0.0, -100.5, -1.0))
  .scale(100.0)

hitables << Hitable::Sphere.new(Material::Mirror.new(Color.new(0.8, 0.6, 0.2)))
  .translate(Vector.new(1.0, 0.0, -1.0))
  .scale(0.5)

hitables << Hitable::Sphere.new(Material::Matte.new(Color.new(0.1, 0.2, 0.5)))
  .translate(Vector.new(0.0, 0.0, -1.0))
  .scale(0.5)

hitables << Hitable::Sphere.new(Material::Glass.new(1.8, Color::WHITE, Color::WHITE))
  .translate(Vector.new(-1.0, 0.0, -1.0))
  .scale(0.5)

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
