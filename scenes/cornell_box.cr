require "../src/raytracer"

white = Lambertian.new(Color.new(0.73))
red = Lambertian.new(Color.new(0.65, 0.05, 0.05))
green = Lambertian.new(Color.new(0.12, 0.45, 0.15))
light = DiffuseLight.new(Color.new(15.0))
aluminum = Metal.new(Color.new(0.8, 0.85, 0.88), 0.0)

left = YZRect.new(Point.new(555.0, 0.0, 0.0),
  Point.new(555.0, 555.0, 555.0),
  green)
left.flip!

right = YZRect.new(Point.new(0.0, 0.0, 0.0),
  Point.new(0.0, 555.0, 555.0),
  red)

bottom = XZRect.new(Point.new(0.0, 0.0, 0.0),
  Point.new(555.0, 0.0, 555.0),
  white)

top = XZRect.new(Point.new(0.0, 555.0, 0.0),
  Point.new(555.0, 555.0, 555.0),
  white)
top.flip!

back = XYRect.new(Point.new(0.0, 0.0, 555.0),
  Point.new(555.0, 555.0, 555.0),
  white)
back.flip!

light_ = XZRect.new(Point.new(213.0, 554.0, 227.0),
  Point.new(343.0, 554.0, 332.0),
  light)
light_.flip!

cube1 = Translate.new(
  RotateY.new(
    Cuboid.new(Point.new(0.0), Point.new(165.0), white),
    -18.0
  ),
  Point.new(130.0, 0.0, 65.0)
)

cube2 = Translate.new(
  RotateY.new(
    Cuboid.new(Point.new(0.0), Point.new(165.0, 330.0, 165.0), aluminum),
    15.0
  ),
  Point.new(265.0, 0.0, 295.0)
)

sphere = Sphere.new(
  Point.new(190.0, 90.0, 190.0),
  90.0,
  Dielectric.new(1.5)
)

# hitables = [left, right, bottom, top, back, light_, cube1, cube2]
hitables = [left, right, bottom, top, back, light_, sphere, cube2]

width, height = {400, 400}

camera = Camera.new(
  look_from: Point.new(278.0, 278.0, -800.0),
  look_at: Point.new(278.0, 278.0, 0.0),
  vertical_fov: 40,
  aspect_ratio: width.to_f / height.to_f,
)

raytracer = Raytracer.new(width, height,
  hitables: HitableList.new(hitables),
  focus_hitables: HitableList.new([light_, sphere, cube2]),
  camera: camera,
  samples: 1000,
  background: ConstantBackground.new(Color.new(0.0)))

raytracer.render("cornell.png")
