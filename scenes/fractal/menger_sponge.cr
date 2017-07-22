require "../../src/distance_estimatables/*"
require "../../raytracer"

mat = MatteMaterial.new(UTexture.new(120.0))
de = DE::MengerSponge.new(15)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 1000)

dimensions = {800, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(2.0, 1.0, 1.0),
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 22.0,
  dimensions: dimensions
)

raytracer = Raytracer::Color.new(
  dimensions,
  scene: Scene.new(
    [hitables.as(UnboundedHitable)],
    background: Background::Constant.new(Color.new(1.0))
  ),
  camera: camera,
  samples: 5
)

raytracer.recursion_depth = 1
raytracer.gamma_correction = 1.0 / 4.0

raytracer.render("fractal2.png")
