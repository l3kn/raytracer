require "./vec3"
require "./ray"
require "./hitable"
require "./hitable/*"
require "./camera"
require "./helper"
require "./material"
require "./material/*"
require "./raytracer"
require "./scenes/*"
require "./texture"
require "./bvh"
require "./aabb"

# world = BVHNode.new(random_scene)
world = HitableList.new(test_scene)

# width, height = {800, 400}
width, height = {400, 200}

raytracer = Raytracer.new(width, height)

# Camera params
look_from = Vec3.new(-1.5, 1.5, 1.5)
look_at = Vec3.new(0.0, 0.0, -1.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 30

aspect_ratio = width.to_f / height.to_f
dist_to_focus = (look_from - look_at).length
aperture = 0.05

samples = 1000
# samples = 10

camera = Camera.new(look_from, look_at, up, fov, aspect_ratio, aperture, dist_to_focus)
filename = "main.ppm"
raytracer.render(world, camera, samples, filename)
