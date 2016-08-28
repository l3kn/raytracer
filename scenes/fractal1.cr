require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimator"

class UTexture < Texture
  def initialize
  end

  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    col **= 10.0
  end
end

mat = Lambertian.new(UTexture.new)

de = DE::Mandelbulb.new(iterations: 20)
hitables = DE::DistanceEstimator.new(mat, de, maximum_steps: 500)

width, height = {400, 400}

camera = Camera.new(
  look_from: Vec3.new(2.0, 0.5, 4.5) * 0.8,
  look_at: Vec3.new(0.0, 0.0, 0.0),
  up: Vec3::Y,
  vertical_fov: 32,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.01
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                hitables: hitables,
                                camera: camera,
                                samples: 1,
                                background: ConstantBackground.new(Vec3.new(1.0)))
raytracer.recursion_depth = 1

raytracer.render("fractal.png")
