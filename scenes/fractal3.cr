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


class SierpinskyTetrahedron < DE::DistanceEstimatable
  def initialize(@iterations = 4, @scale = 2.0)
  end

  def distance_estimate(pos)
    x, y, z = pos.tuple
    @iterations.times do
      # Folding across some of the symmetry planes
      if x+y < 0
        t = -y
        y = -x
        x = t
      end

      if x+z < 0
        t = -z
        z = -x
        x = t
      end

      if y+z < 0
        t = -z
        z = -y
        y = t
      end

      x = @scale*x - (@scale-1)
      y = @scale*y - (@scale-1)
      z = @scale*z - (@scale-1)
    end

    r = x*x + y*y + z*z
    (Math.sqrt(r) - 2) * @scale ** (-@iterations)
  end
end

mat = Lambertian.new(UTexture.new)

de = SierpinskyTetrahedron.new(11, 2.0)
hitables = DE::DistanceEstimator.new(mat, de, maximum_steps: 600)

width, height = {1920, 1080}
# width, height = {800, 800}

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
                                samples: 10,
                                background: ConstantBackground.new(Vec3.new(1.0)),
                                recursion_depth: 1)

raytracer.render("fractal3.png")
