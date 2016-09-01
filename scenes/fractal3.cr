require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimatable"

class UTexture < Texture
  def initialize
  end

  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    col **= 40.0
  end
end

class SierpinskyTetrahedron < DE::DistanceEstimatable
  def initialize(@iterations = 4, @scale = 2.0)
  end

  def distance_estimate(pos)
    @iterations.times do
      # Folding across some of the symmetry planes
      pos = pos._y_xz if pos.x + pos.y < 0
      pos = pos._zy_x if pos.x + pos.z < 0
      pos = pos.x_z_y if pos.y + pos.z < 0

      pos = pos*@scale - (@scale - 1.0)
    end

    (pos.length - 2) * @scale ** (-@iterations)
  end
end

mat = Lambertian.new(UTexture.new)

de = SierpinskyTetrahedron.new(11, 2.0)
hitables = DistanceEstimator.new(mat, de, maximum_steps: 600)

# width, height = {1920, 1080}
width, height = {400, 400}

camera = Camera.new(
  look_at: Vec3.new(1.0),
  look_from: Vec3.new(0.0),
  up: Vec3::Y,
  vertical_fov: 22,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.00
)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
  hitables: hitables,
  camera: camera,
  samples: 3,
  background: ConstantBackground.new(Vec3.new(1.0)))
raytracer.recursion_depth = 1

raytracer.render("fractal3.png")
