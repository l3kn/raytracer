def test_scene
  world = [] of Hitable

  ch1 = ConstantTexture.new(Vec3.new(0.8))
  ch2 = ConstantTexture.new(Vec3.new(0.2))

  tex1 = CheckerTexture.new(ch1, ch2)

  tex2 = ConstantTexture.new(Vec3.new(0.1, 0.2, 0.5))
  tex3 = ConstantTexture.new(Vec3.new(0.8, 0.6, 0.2))

  # world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Metal.new(tex1, 0.0)))
  world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Lambertian.new(tex1)))
  world.push(Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5, Lambertian.new(tex2)))
  world.push(Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, Metal.new(tex3, 0.0)))
  world.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))
end
