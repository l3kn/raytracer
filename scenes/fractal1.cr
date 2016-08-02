require "../src/raytracers/simple_src/raytracer"
require "../src/raytracers/cube_map_src/raytracer"
require "../src/distance_estimator"

ct1 = ConstantTexture.new(Vec3.new(0.9))
mat = Lambertian.new(ct1)

de = DE::Mandelbulb.new(iterations: 10)
world = DE::DistanceEstimator.new(mat, de)

width, height = {400, 400}

# Camera params
look_from = Vec3.new(2.0, 0.5, 4.5)
look_at = Vec3.new(0.0, 0.0, 0.0)

up = Vec3.new(0.0, 1.0, 0.0)
fov = 30

aspect_ratio = width.to_f / height.to_f
src/dist_to_focus = (look_from - look_at).length
aperture = 0.05

camera = OldCamera.new(look_from, look_at, up, fov, aspect_ratio)

# Raytracer
src/raytracer = SimpleRaytracer.new(width, height,
                                world: world,
                                camera: camera,
                                samples: 5, debug: true)

src/raytracer.render("fractal.png")
