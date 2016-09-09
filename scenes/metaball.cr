require "../src/raytracer"
require "../src/hitables/distance_estimator"
require "../src/backgrounds/*"
require "../src/distance_estimatables/*"

mat = Metal.new(Vec3.new(0.8), 0.0)

class BFMeta < DE::BruteForceDistanceEstimatable
  def initialize
    @points = [
      {Vec3.new(1.0, -0.5, -0.2), 1.0},
      {Vec3.new(0.0, 0.5, 0.2), 1.0},
      {Vec3.new(-1.0, -0.5, 0.0), 1.0},
    ]
  end

  def inside?(pos)
    potential = 0.0

    @points.each do |p_i, r_i|
      potential += r_i / (pos - p_i).squared_length
    end

    potential > 3.4
  end

  def normal(pos)
    n = Vec3::ZERO
    @points.each do |p_i, r_i|
      a = -2.0 * r_i
      b = p_i - pos
      c = (p_i - pos).squared_length
      n = n + b * (a / c) 
    end

    n.normalize
  end
end

bfde = BFMeta.new
hitables = BruteForceDistanceEstimator.new(mat, bfde, 10.0)

width, height = {800, 400}

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
