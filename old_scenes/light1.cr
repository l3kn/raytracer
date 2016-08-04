require "../src/raytracers/simple_raytracer"

class TestTexture < Texture
  def initialize(@scale = 1.0)
    @noise = Perlin.new(100)
  end

  def value(point, u, v)
    # n = @noise.octave_perlin(point, 8, 0.5)
    # v = 0.5*(1 + Math.sin(@scale * point.z + 10*n))
    # Vec3.new(v)
    Vec3.new(@noise.octave_perlin(point * @scale, 7, 0.5))
  end
end

world = [] of Hitable

ch1 = ConstantTexture.new(Vec3.new(0.8))
ch2 = ConstantTexture.new(Vec3.new(0.2))

tex1 = CheckerTexture.new(ch1, ch2)

tex2 = TestTexture.new(10.0)
tex3 = ConstantTexture.new(Vec3.new(0.8, 0.6, 0.2))

l1 = ConstantTexture.new(Vec3.new(10.0))

world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Lambertian.new(tex1)))

world.push(Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5, Lambertian.new(tex2)))
world.push(Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, Metal.new(tex3, 0.0)))
world.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))

world.push(XYRect.new(Vec3.new(-4.0, 1.0, -2.0),
                      Vec3.new(-2.0, 3.0, -2.0),
                      DiffuseLight.new(l1)))

width, height = {800, 400}

# Camera params
look_from = Vec3.new(-1.5, 1.5, 1.5)
look_at = Vec3.new(0.0, 0.0, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 30

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.05

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)

# Raytracer
raytracer = SimpleRaytracer.new(width, height,
                                world: HitableList.new(world),
                                camera: camera,
                                samples: 2000)

raytracer.render("light1.png")
