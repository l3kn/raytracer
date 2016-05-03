require "../raytracer"

world_ = [] of Hitable

white = ConstantTexture.new(Vec3.new(0.8))
world_.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, Lambertian.new(white)))

world_.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))
world_.push(Sphere.new(Vec3.new( 0.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))
world_.push(Sphere.new(Vec3.new( 1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8)))

bri = 20.0

red =   ConstantTexture.new(Vec3.new(bri, 0.0, 0.0))
green = ConstantTexture.new(Vec3.new(0.0, bri, 0.0))
blue =  ConstantTexture.new(Vec3.new(0.0, 0.0, bri))

height = 2.0
size = 0.4

world_.push(XZRect.new(Vec3.new(-1.0-size, height, -1.0-size),
                       Vec3.new(-1.0+size, height, -1.0+size),
                       DiffuseLight.new(red)))

world_.push(XZRect.new(Vec3.new( 0.0-size, height, -1.0-size),
                       Vec3.new( 0.0+size, height, -1.0+size),
                       DiffuseLight.new(green)))

world_.push(XZRect.new(Vec3.new( 1.0-size, height, -1.0-size),
                       Vec3.new( 1.0+size, height, -1.0+size),
                       DiffuseLight.new(blue)))

world = HitableList.new(world_)

width, height = {800, 400}

raytracer = Raytracer.new(width, height)

# Camera params
look_from = Vec3.new(0.0, 1.5, 1.5)
look_at = Vec3.new(0.0, 0.0, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 35

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.05

samples = 2000

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)
filename = "light2.ppm"
raytracer.render(world, camera, samples, filename)
