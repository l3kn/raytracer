require "../../src/distance_estimatables/*"
require "../../raytracer"

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
    max = Point.new(@folding_limit)
    z = Point.new(
      clamp(z.x, -max.x, max.x) * 2.0 - z.x,
      clamp(z.y, -max.y, max.y) * 2.0 - z.y,
      clamp(z.z, -max.z, max.z) * 2.0 - z.z,
    )
    {z, dz}
  end
end

mat = Material::Matte.new(Texture::U.new)

de = Mandelbox.new(10)
hitables = DistanceEstimator.new(
  mat,
  de,
  step: 0.0001,
  maximum_steps: 1000000,
  minimum_distance: 0.0001
)

dimensions = {800, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(4.5, 0.0, 1.0),
  look_at: Point.new(0.0, 0.0, -3.0),
  vertical_fov: 25.0,
  dimensions: dimensions
)

# Raytracer
raytracer = Raytracer::Color.new(
  dimensions,
  scene: Scene.new(
    [hitables.as(Hitable)],
    background: Background::Constant.new(Color.new(1.0))
  ),
  camera: camera,
  samples: 10
)

raytracer.render("fractal.png")
