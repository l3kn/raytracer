require "./vec3"
require "./ray"
require "./hitable"
require "./camera"
require "./helper"
require "./material"
require "./raytracer"

width = 400
height = 200

lam1 = Lambertian.new(Vec3.new(0.8, 0.3, 0.3))
lam2 = Lambertian.new(Vec3.new(0.8, 0.8, 0.0))
met1 = Metal.new(Vec3.new(0.8, 0.6, 0.2))
met2 = Metal.new(Vec3.new(0.8))

die1 = Dielectric.new(1.5)

world = HitableList.new
world.push(Sphere.new(Vec3.new(-1.0, 0.0, -1.0), 0.5, die1))
world.push(Sphere.new(Vec3.new(0.0, 0.0, -1.0), 0.5, met2))
world.push(Sphere.new(Vec3.new(1.0, 0.0, -1.0), 0.5, met1))
world.push(Sphere.new(Vec3.new(0.0, -100.5, -1.0), 100.0, lam2))

# Camera params

raytracer = Raytracer.new(width, height)

look_at = Vec3.new(0.0, 0.0, -1.0)
up = Vec3.new(0.0, 1.0, 0.0)
fov = 90
samples = 100

(0...100).each do |i|
  puts "Rendering image #{i}"

  look_from = Vec3.new(-2.0+(4.0 / 100 * i), 0.0, 0.0)
  camera = Camera.new(look_from, look_at, up, fov, width.to_f / height)
  filename = "images/#{i.to_s.rjust(3, '0')}.ppm"
  raytracer.render(world, camera, samples, filename)
end
