require "../src/raytracer"
require "../src/hitables/distance_estimator"
require "../src/backgrounds/*"
require "../src/distance_estimatables/*"

mat = Lambertian.new(UTexture.new(1.0))

class Metaball < DE::DistanceEstimatable
  def distance_estimate(pos)
    points = [
      {Vec3.new(1.0, 0.0, 0.0), 1.0},
      {Vec3.new(-1.0, 0.0, 0.0), 1.0}
    ]

    potential = 0.0

    points.each do |target, target_potential|
      dist = (target - pos).length
      potential += dist
    end

    (potential - 1.0).abs
  end
end

# class BFSphere < DE::BruteForceDistanceEstimatable
  # def inside?(pos)
    # pos.length < 1.0
  # end
# end

class BFMeta < DE::BruteForceDistanceEstimatable
  def initialize
    @points = [
      {Vec3.new(1.0, 0.0, 0.0), 1.0},
      {Vec3.new(-1.0, 0.0, 0.0), 1.0}
    ]
  end

  def inside?(pos)
    potential = 0.0

    @points.each do |p_i, r_i|
      potential += (r_i ** 2) / (pos - p_i).squared_length
    end

    potential > 1.6
  end

  def normal(pos)
    normal = Vec3::ZERO
    @points.each do |p_i, r_i|
      normal = normal + (pos - p_i) * (2 * (r_i ** 2) / ((pos - p_i).squared_length ** 2))
    end

    normal.normalize
  end
end

# de = Metaball.new
bfde = BFMeta.new
# hitables = DistanceEstimator.new(mat, de, maximum_steps: 10000)
hitables = BruteForceDistanceEstimator.new(mat, bfde)

width, height = {200, 200}

camera = Camera.new(
  look_from: Vec3.new(0.0, 0.0, 10.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  vertical_fov: 25,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = NormalRaytracer.new(
  width, height,
  hitables: hitables,
  camera: camera,
  samples: 10,
  background: ConstantBackground.new(Vec3::ZERO))
raytracer.gamma_correction = 1.0

raytracer.render("meta.png")
