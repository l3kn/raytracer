require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimator"
require "../src/distance_estimatable"
require "../src/distance_estimatables/*"
require "../src/quaternion"

class UTexture < Texture
  def initialize
  end

  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    col **= 40.0
  end
end


class Julia < DE::DistanceEstimatable
  def initialize(@iterations = 4)
    # @c = Quaternion.new(0.18, 0.88, 0.24, 0.16)
    @c = Quaternion.new(-0.137,-0.630,-0.475,-0.046)
    @c = Quaternion.new(-0.218,-0.113,-0.181,-0.496)

  end

  def distance_estimate(pos)
    p = Quaternion.new(pos.x, pos.y, pos.z, 0.0)
    dp = Quaternion.new(1.0, 0.0, 0.0, 0.0)

    @iterations.times do
      dp = Quaternion.new(
        p.x*p.x - p.yzw.squared_length,
        dp.yzw * p.x + p.yzw*dp.x + p.yzw.cross(dp.yzw)
      ) * 2.0

      p = Quaternion.new(
        p.x*p.x - p.yzw.squared_length,
        p.yzw * p.x * 2.0
      ) + @c

      p2 = p.squared_length
      break if p2 > 100.0
    end

    r = p.length
    0.5 * r * Math.log(r) / dp.length
  end
end

mat = Lambertian.new(UTexture.new)

de = Julia.new(5)
hitables = DE::DistanceEstimator.new(mat, de, maximum_steps: 500)

# width, height = {1920, 1080}
width, height = {400, 400}

camera = Camera.new(
  look_from: Vec3.new(3.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  up: Vec3::Y,
  vertical_fov: 30,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.00
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                hitables: hitables,
                                camera: camera,
                                samples: 5,
                                background: SkyBackground.new,
                                recursion_depth: 1)

raytracer.render("fractal5.png")
