require "../src/raytracer"

floor = Sphere.new(Point.new(0.0, -100.5, -1.0), 100.0, Lambertian.new(Color.new(0.8)))

sphere1 = Sphere.new(Point.new(-1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8))
sphere2 = Sphere.new(Point.new(0.0, 0.0, -1.0), 0.5, Dielectric.new(1.8))
sphere3 = Sphere.new(Point.new(1.0, 0.0, -1.0), 0.5, Dielectric.new(1.8))

bri = 20.0

red = Color.new(bri, 0.0, 0.0)
green = Color.new(0.0, bri, 0.0)
blue = Color.new(0.0, 0.0, bri)

height = 2.0
size = 0.4

light1 = XZRect.new(Point.new(-1.0 - size, height, -1.0 - size),
  Point.new(-1.0 + size, height, -1.0 + size),
  DiffuseLight.new(red))
light1.flip!

light2 = XZRect.new(Point.new(0.0 - size, height, -1.0 - size),
  Point.new(0.0 + size, height, -1.0 + size),
  DiffuseLight.new(green))
light2.flip!

light3 = XZRect.new(Point.new(1.0 - size, height, -1.0 - size),
  Point.new(1.0 + size, height, -1.0 + size),
  DiffuseLight.new(blue))
light3.flip!

width, height = {800, 400}

camera = Camera.new(
  look_from: Point.new(0.0, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 35,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = Raytracer.new(width, height,
  hitables: FiniteHitableList.new([light1, light2, light3, sphere1, sphere2, sphere3, floor]),
  focus_hitables: FiniteHitableList.new([light1, light2, light3, sphere1, sphere2, sphere3]),
  camera: camera,
  samples: 20,
  background: ConstantBackground.new(Color::BLACK))

raytracer.render("light2.png")
