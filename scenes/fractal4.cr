require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatable"

class Octahedron < DE::DistanceEstimatable
  def initialize(@iterations = 4, @scale = 4.0)
  end

  def distance_estimate(pos)
    @iterations.times do
      pos = pos._y_xz if pos.x + pos.y < 0.0
      pos = pos._zy_x if pos.x + pos.z < 0.0
      pos = pos.yxz if pos.x - pos.y < 0.0
      pos = pos.zyx if pos.x - pos.z < 0.0

      pos = pos * @scale - (@scale - 1.0)
    end

    pos.length * (@scale ** (-@iterations))
  end
end

mat = Lambertian.new(UTexture.new(40.0))

de = Octahedron.new(1, 2.0)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 1000)

# width, height = {1920, 1080}
width, height = {800, 400}

camera = Camera.new(
  look_from: Vec3.new(10.0),
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
  samples: 1,
  background: SkyBackground.new)
raytracer.recursion_depth = 1

raytracer.render("fractal4.png")
