require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatable"
require "../src/quaternion"

class UTexture < Texture
  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    # col **= 20.0
  end
end


class Mandelbox < DE::DistanceEstimatable
  def initialize(@iterations = 4, @scale = 2.9)
    @min_radius = 0.5
    @fixed_radius = 1.0
    @min_radius_2 = 0.25
    @fixed_radius_2 = 1.4

    @folding_limit = 1.0
  end

  def distance_estimate(pos)
    offset = pos
    dr = 1.0

    @iterations.times do
      pos, dr = box_fold(pos, dr)
      pos, dr = sphere_fold(pos, dr)
      pos = pos * @scale + offset
      dr = dr * @scale.abs + 1.0
    end

    r = pos.length
    r / dr.abs
  end

  def sphere_fold(z, dz)
    r2 = z.squared_length
    if r2 < @min_radius_2
      tmp = @fixed_radius_2 / @min_radius_2
    elsif r2 < @fixed_radius_2
      tmp = @fixed_radius_2 / r2
    else
      tmp = 1.0
    end
    {z * tmp, dz * tmp}
  end

  def box_fold(z, dz)
    max = Vec3.new(@folding_limit)
    z = z.clamp(-max, max) * 2.0 - z
    {z, dz}
  end
end

# mat = Lambertian.new(UTexture.new)
mat = Lambertian.new(UTexture.new)

de = Mandelbox.new(10)
hitables = DistanceEstimator.new(
  mat,
  de,
  step: 0.0001,
  maximum_steps: 1000000,
  minimum_distance: 0.0001
)

# width, height = {1920, 1080}
width, height = {192 * 5, 108 * 5}
# width, height = {800, 800}

camera = Camera.new(
  look_from: Vec3.new(4.5, 0.0, 1.0),
  look_at: Vec3.new(0.0, 0.0, -3.0),
  up: Vec3::Y,
  vertical_fov: 25,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.00
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height, hitables: hitables, camera: camera, samples: 40)
raytracer.recursion_depth = 1
raytracer.gamma_correction = 1.0
raytracer.t_max = 10000.0
raytracer.render("fractal6.png")
