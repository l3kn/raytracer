require "../src/raytracer"
require "../src/backgrounds/*"
require "../src/distance_estimator"
require "../src/distance_estimatable"

class UTexture < Texture
  def initialize
  end

  def value(point, u, v)
    col = Vec3::ONE * (1 - u)
    col **= 40.0
  end
end


class MengerSponge < DE::DistanceEstimatable
  def initialize(@iterations = 4)
  end

  def distance_estimate_foo(pos)
    a1 = Vec3.new( 1.0,  1.0,  1.0)
    a2 = Vec3.new(-1.0, -1.0,  1.0)
    a3 = Vec3.new( 1.0, -1.0, -1.0)
    a4 = Vec3.new(-1.0,  1.0, -1.0)

    c = Vec3::ZERO
    n = 0

    dist = 0.0
    d = 0.0

    @iterations.times do
      c = a1
      dist = (pos - a1).length

      d = (pos - a2).length
      if d < dist
        c = a2
        dist = d
      end

      d = (pos - a3).length
      if d < dist
        c = a3
        dist = d
      end

      d = (pos - a4).length
      if d < dist
        c = a4
        dist = d
      end

      pos = pos*@scale - c*(@scale-1)
      n += 1
    end

    pos.length * (@scale ** (-n.to_f))
  end

  def distance_estimate(pos)
    t = 0.0
    x, y, z = pos.xyz

    @iterations.times do
      x = x.abs
      y = y.abs
      z = z.abs

      if x < y
        t = x
        x = y
        y = t
      end

      if y < z
        t = y
        y = z
        z = t
      end

      if x < y
        t = x
        x = y
        y = t
      end

      x = x * 3.0 - 2.0
      y = y * 3.0 - 2.0
      z = z * 3.0 - 2.0

      z += 2.0 if z < -1.0
    end

    (Math.sqrt(x*x + y*y + z*z) - 1.5) * (3.0 ** (-@iterations))
  end
end

mat = Lambertian.new(UTexture.new)

de = MengerSponge.new(15)
hitables = DE::DistanceEstimator.new(mat, de, maximum_steps: 600)

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
                                samples: 3,
                                background: SkyBackground.new,
                                recursion_depth: 1)

raytracer.render("fractal2.png")
