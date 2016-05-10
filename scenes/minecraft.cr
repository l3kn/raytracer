require "../simple_raytracer"
require "./minecraft/textures"

textures = MinecraftTextures.load 

wood1 = Lambertian.new(textures[4])
wood2 = Lambertian.new(textures[20])
stone = Lambertian.new(textures[1])
brick = Lambertian.new(textures[7])
diamond = Lambertian.new(textures[50])
gold = Metal.new(textures[23], 0.0)

world = [] of Hitable

def block(x, y, z, tex)
  x = x.to_f
  y = y.to_f
  z = z.to_f

  Cuboid.new(Vec3.new(x, y, z),
             Vec3.new(x + 1, y + 1, z + 1),
             tex)
end

world << block(3, 0, 0, wood2)
world << block(3, 1, 0, wood2)

world << block(3, 0, 1, wood1)
world << block(3, 0, 2, wood1)
world << block(3, 0, 3, wood1)

world << block(3, 0, 4, wood2)
world << block(3, 1, 4, wood2)

world << block(4, 0, 0, wood1)
world << block(4, 1, 0, wood1)

world << block(5, 2, 0, gold)

world << block(6, 0, 0, wood1)
world << block(6, 1, 0, wood1)

world << block(7, 0, 0, wood2)
world << block(7, 1, 0, wood2)

world << block(7, 0, 1, wood1)
world << block(7, 0, 2, wood1)
world << block(7, 0, 3, wood1)

world << block(7, 0, 4, wood2)
world << block(7, 1, 4, wood2)

world << block(4, 0, 3, wood1)
world << block(4, 1, 3, wood1)

world << block(5, 0, 3, wood1)
world << block(5, 1, 3, wood1)

world << block(6, 0, 3, wood1)
world << block(6, 1, 3, wood1)

world << block(4, 2, 1, brick)
world << block(5, 2, 1, brick)
world << block(6, 2, 1, brick)

world << block(4, 2, 2, brick)
world << block(5, 2, 2, brick)
world << block(6, 2, 2, brick)

world << block(4, 2, 3, brick)
world << block(5, 2, 3, brick)
world << block(6, 2, 3, brick)

ct1 = ConstantTexture.new(Vec3.new(0.8))

world.push(Sphere.new(Vec3.new(4.0, -100.0, 0.0), 100.1, Metal.new(ct1, 0.0)))
world.push(Sphere.new(Vec3.new(0.0, 1.5, 1.0), 1.5, Lambertian.new(textures[50])))
world.push(Sphere.new(Vec3.new(11.0, 1.5, 1.0), 1.5, Dielectric.new(1.8)))

width, height = {800, 400}

# Camera params
look_from = Vec3.new(15.5, 5.0, -8.0)
look_at = Vec3.new(5.5, 0.0, 3.0)

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
                                samples: 50)

raytracer.render("minecraft.ppm")
