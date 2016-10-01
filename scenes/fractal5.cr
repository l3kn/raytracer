require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatable"
require "../src/quaternion"


class Julia < DE::DistanceEstimatable
  def initialize(@iterations = 4)
    # @d = Quaternion.new(0.18, 0.88, 0.24, 0.16)
    @d = Quaternion.new(-0.137, -0.630, -0.475, -0.046)
    # @d = Quaternion.new(-0.218,-0.113,-0.181,-0.496)
  end

  def distance_estimate(pos)
    p = Quaternion.new(pos, 0.0)
    dp = Quaternion.new(1.0, 0.0, 0.0, 0.0)

    @iterations.times do
      dp = p*dp*2.0
      p = p * p + @d
      break if p.squared_length > 10000000.0
    end

    r = p.length
    0.5 * r * Math.log(r) / dp.length
  end
end

mat = Lambertian.new(UTexture.new(20.0))

de = Julia.new(100)
hitables = DistanceEstimator.new(
  mat,
  de,
  maximum_steps: 1000,
  minimum_distance: 0.0001
)

width, height = {1920, 1080}
# width, height = {400, 400}

camera = Camera.new(
  look_from: Point.new(4.0, 0.0, 0.0),
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 30,
  aspect_ratio: width.to_f / height.to_f,
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height, hitables: hitables, camera: camera, samples: 5)
raytracer.recursion_depth = 1
raytracer.t_max = 100.0
raytracer.render("fractal5.png")
