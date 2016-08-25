require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimator"

mat = Lambertian.new(Vec3.new(0.9))
de = DE::Mandelbulb.new(iterations: 10)
hitables = DE::DistanceEstimator.new(mat, de)

width, height = {200, 200}

camera = Camera.new(
  look_from: Vec3.new(2.0, 0.5, 4.5),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  up: Vec3::Y,
  vertical_fov: 30,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.05
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                hitables: hitables,
                                camera: camera,
                                samples: 1,
                                background: ConstantBackground.new(Vec3.new(1.0)))

raytracer.render("fractal.png")
