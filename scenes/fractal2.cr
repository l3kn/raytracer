require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimator"
require "../src/distance_estimatable"
require "../src/distance_estimatables/*"

class UTexture < Texture
  def initialize
  end

  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    col **= 40.0
  end
end

mat = Lambertian.new(UTexture.new)
de = DE::MengerSponge.new(15)
hitables = DE::DistanceEstimator.new(mat, de, maximum_steps: 1000)

# width, height = {1920, 1080}
width, height = {800, 400}

camera = Camera.new(
  look_from: Vec3.new(2.0, 1.0, 1.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  up: Vec3::Y,
  vertical_fov: 22,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.00
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                hitables: hitables,
                                camera: camera,
                                samples: 4,
                                background: SkyBackground.new)
raytracer.recursion_depth = 1

raytracer.render("fractal2.png")
