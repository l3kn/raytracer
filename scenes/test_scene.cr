require "./../texture"

class TestTexture < Texture
  def initialize(@scale = 1.0)
    @noise = Perlin.new(100)
  end

  def value(point)
    # n = @noise.octave_perlin(point, 8, 0.5)
    # v = 0.5*(1 + Math.sin(@scale * point.z + 10*n))
    # Vec3.new(v)
    Vec3.new(@noise.octave_perlin(point * @scale, 7, 0.5))
  end
end

def test_scene
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
  world.push(XYRect.new(-4, -2, 1, 3, -2, DiffuseLight.new(l1)))
end
