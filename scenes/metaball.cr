require "../src/raytracer"
require "../src/hitables/distance_estimator"
require "../src/backgrounds/*"
require "../src/distance_estimatables/*"

mat = Metal.new(Vec3.new(0.8), 0.0)

bfde = DE::Metaball.new(
  [
    {Vec3.new(1.0, -0.5, -0.2), 1.0},
    {Vec3.new(0.0, 0.5, 0.2), 1.0},
    {Vec3.new(-1.0, -0.5, 0.0), 1.0},
  ],
  3.4
)
hitables = BruteForceDistanceEstimator.new(mat, bfde, 5.0)

# width, height = {800, 400}
width, height = {1920, 1080}

camera = Camera.new(
  look_from: Vec3.new(0.0, 0.0, 2.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  vertical_fov: 70,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = SimpleRaytracer.new(
  width, height,
  hitables: hitables,
  camera: camera,
  samples: 10,
  background: CubeMap.new("cube_maps/Yokohama"))
raytracer.gamma_correction = 1.0

raytracer.render("metaball.png")
