require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatables/*"

mat = Lambertian.new(UTexture.new(10.0))
de = DE::Mandelbulb.new(iterations: 20)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 500)

width, height = {400, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(2.0, 0.5, 4.5) * 0.8,
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 32.0,
  dimensions: {width, height}
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
  hitables: hitables,
  camera: camera,
  samples: 1,
  background: ConstantBackground.new(Color.new(1.0)))
raytracer.recursion_depth = 1

raytracer.render("fractal.png")
