require "./../texture"

def benchmark_scene
  world = [] of Hitable

  ct1 = ConstantTexture.new(Vec3.new(0.8))
  ct2 = ConstantTexture.new(Vec3.new(0.1, 0.2, 0.5))
  ct3 = ConstantTexture.new(Vec3.new(0.8, 0.6, 0.2))

  world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Metal.new(ct1, 0.0)))
  world.push(Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5, Lambertian.new(ct2)))
  world.push(Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, Metal.new(ct3, 0.0)))
  world.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))
end
