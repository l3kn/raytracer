require "../src/raytracer"

light = Sphere.new(Vec3.new(0.0, 0.0, 1.0), 1.0, DiffuseLight.new(Vec3.new(40.0)))
floor = Sphere.new(Vec3.new(0.0, -1000.0, 0.0), 1000.0, Lambertian.new(Vec3.new(0.8)))

world = [light]
width, height = {800, 400}

20.times do
  origin = random_in_unit_circle
  x = origin.x * 10.0
  z = origin.y * 10.0

  r = pos_random
  g = pos_random * (1.0 - r)
  b = (1 - r - g)

  radius = 0.7

  world.push(
    Sphere.new(
      Vec3.new(x, radius, z),
      radius,
      Lambertian.new(Vec3.new(r, r, b))
    )
  )
end

camera = Camera.new(
  look_from: Vec3.new(0.0, 20.0, 20.0),
  look_at: Vec3.new(0.0, 0.0, 0.0),
  vertical_fov: 35,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.05
)

raytracer = Raytracer.new(width, height,
  hitables: HitableList.new([floor, BVHNode.new(world)]),
  focus_hitables: HitableList.new([light]),
  camera: camera,
  samples: 100,
  background: ConstantBackground.new(Vec3.new(0.0)))

raytracer.render("spheres.png")
