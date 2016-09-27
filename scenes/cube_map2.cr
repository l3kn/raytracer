require "../src/raytracer"
require "../src/backgrounds/*"

sphere1 = Sphere.new(
  Point.new(-1.6, -0.3, -1.6),
  0.7,
  Metal.new(Color.new(0.8), 0.0)
)

sphere2 = Sphere.new(
  Point.new(1.6, -0.3, 0.0),
  0.7,
  Dielectric.new(3.0)
)

floor = XZRect.new(
  Point.new(-3.0, -1.0, -3.0),
  Point.new(3.0, -1.0, 3.0),
  Lambertian.new(Color.new(0.9))
)

width, height = {600, 400}

camera = Camera.new(
  look_from: Point.new(0.0, 0.6, 2.0) * 2.2,
  look_at: Point.new(0.0, 0.0, 0.0),
  vertical_fov: 50,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.1
)

raytracer = Raytracer.new(width, height,
  hitables: FiniteHitableList.new([sphere1, sphere2, floor]),
  focus_hitables: sphere2,
  camera: camera,
  samples: 1000,
  background: CubeMap.new("cube_maps/Yokohama"))

raytracer.render("cube_map2.png")
