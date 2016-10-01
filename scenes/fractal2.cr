require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatables/*"

mat = Lambertian.new(UTexture.new(40.0))
de = DE::MengerSponge.new(15)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 1000)

# width, height = {1920, 1080}
width, height = {800, 400}

camera = Camera.new(
  look_from: Point.new(2.0, 1.0, 1.0),
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 22,
  aspect_ratio: width.to_f / height.to_f,
)

# Raytracer
raytracer = SingleRaytracer.new(width, height,
  hitables: hitables,
  camera: camera,
  samples: 4,
  background: SkyBackground.new)
raytracer.recursion_depth = 1

raytracer.render("fractal2.png")
