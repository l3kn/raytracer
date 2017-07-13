require "../../src/distance_estimatables/*"
require "../../raytracer"

mat = MatteMaterial.new(UTexture.new(10.0))
de = DE::Mandelbulb.new(iterations: 20)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 500)

dimensions = {800, 800}
camera = PerspectiveCamera.new(
  look_from: Point.new(2.0, 0.5, 4.5) * 0.8,
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 32.0,
  dimensions: dimensions
)

# Raytracer
raytracer = ColorRaytracer.new(
  dimensions,
  scene: Scene.new(
    [hitables.as(Hitable)],
    [] of Light,
    ConstantBackground.new(Color.new(1.0))
  ),
  camera: camera,
  samples: 10)

raytracer.render("fractal.png")
