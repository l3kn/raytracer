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


class MengerSponge < DE::DistanceEstimatable
  def initialize(@iterations = 4, @scale = 3.0)
  end

  def distance_estimate(pos)
    dist = Float64.max
    t = 0.0

    @iterations.times do
      pos = pos.abs

      pos = pos.yxz if pos.x < pos.y
      pos = pos.xzy if pos.y < pos.z
      pos = pos.yxz if pos.x < pos.y

      pos = pos * @scale - (@scale - 1.0)
      pos = Vec3.new(pos.xy, pos.z + (@scale - 1.0)) if pos.z < -0.5 * (@scale - 1.0)
    end

    # (pos.length - 1.5) * (@scale ** (-@iterations))
    pos.length * (@scale ** (-@iterations))
  end
end

mat = Lambertian.new(UTexture.new)

de = MengerSponge.new(15, 3.1)
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
                                background: SkyBackground.new,
                                recursion_depth: 1)

raytracer.render("fractal4.png")
