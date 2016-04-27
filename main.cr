require "./vec3"
require "./ray"
require "./hitable"
require "./camera"
require "./helper"
require "./material"
require "./raytracer"
require "./random_scene"

world = random_scene

width = 400
height = 200

raytracer = Raytracer.new(width, height)

# Camera params
look_from = Vec3.new(0.0, 0.8, 3.0)
look_at = Vec3.new(0.0, 0.3, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 20

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.0

samples = 100

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)
filename = "main.ppm"
raytracer.render(world, camera, samples, filename)
