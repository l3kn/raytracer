require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatable"
require "../src/distance_estimator"
require "../src/distance_estimatables/*"

mat = Lambertian.new(Vec3::ONE)
de = DE::Repeat.new(DE::Sphere.new(0.8), Vec3.new(1.0, 0.0, 1.0))
hitables = DE::DistanceEstimator.new(mat, de, 0.1)

# width, height = {1920, 1080}
width, height = {1920, 1080}

camera = Camera.new(
  look_from: Vec3.new(6.0, 3.0, 3.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  up: Vec3::Y,
  vertical_fov: 30,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.05
)

raytracer = NormalRaytracer.new(width, height,
  hitables: hitables,
  camera: camera,
  samples: 1,
  background: SkyBackground.new)

raytracer.render("sphere_test.png")
