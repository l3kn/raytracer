require "../src/raytracers/simple_src/raytracer"

world = [] of Hitable

ct1 = ConstantTexture.new(Vec3.new(0.8))
ct2 = ConstantTexture.new(Vec3.new(0.1, 0.2, 0.5))
ct3 = ConstantTexture.new(Vec3.new(0.8, 0.6, 0.2))

world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Metal.new(ct1, 0.0)))
world.push(Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5, Lambertian.new(ct2)))
world.push(Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, Metal.new(ct3, 0.0)))
world.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))

width, height = {800, 400}

# Camera params
look_from = Vec3.new(-1.5, 1.5, 1.5)
look_at = Vec3.new(0.0, 0.0, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 30

aspect_ratio = width.to_f / height.to_f
src/dist_to_focus = (look_from - look_at).length
aperture = 0.05

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, src/dist_to_focus)

# Raytracer
src/raytracer = SimpleRaytracer.new(width, height,
                                world: HitableList.new(world),
                                camera: camera,
                                samples: 50)

src/raytracer.render("benchmark.png")
