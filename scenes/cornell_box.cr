require "../raytracer"

white = Material::Matte.new(Color.new(0.73))
red = Material::Matte.new(Color.new(0.65, 0.05, 0.05))
green = Material::Matte.new(Color.new(0.12, 0.45, 0.15))
aluminum = Material::Mirror.new(Color.new(0.8, 0.85, 0.88))

lbf = Point.new(0.0, 0.0, 0.0)       # Left | Bottom | Front
rtb = Point.new(555.0, 555.0, 555.0) # Right | Top | Back

hitables = [] of Hitable
lights = [] of Light
hitables << Hitable::XZRect.new(lbf, Point.new(555.0, 0.0, 555.0), white)
hitables << Hitable::YZRect.new(lbf, Point.new(0.0, 555.0, 555.0), red)
hitables << Hitable::YZRect.new(Point.new(555.0, 0.0, 0.0), rtb, green).flip!
hitables << Hitable::XZRect.new(Point.new(0.0, 555.0, 0.0), rtb, white).flip!
hitables << Hitable::XYRect.new(Point.new(0.0, 0.0, 555.0), rtb, white).flip!

hitables << Hitable::Cuboid.new(Point.new(0.0), Point.new(165.0, 330.0, 165.0), aluminum)
  .translate(Vector.new(265.0, 0.0, 295.0))
  .rotate_y(15.0)

hitables << Hitable::Sphere.new(Material::Glass.new(1.5))
  .translate(Vector.new(190.0, 90.0, 190.0))
  .scale(90.0)

light_object, light_light = Light::Area.with_object(
  Hitable::XZRect.new(
    Point.new(213.0, 554.0, 227.0),
    Point.new(343.0, 554.0, 332.0),
    Material::DiffuseLight.new(Color.new(15.0))
  ).flip!,
  Color.new(15.0)
)

lights << light_light
hitables << light_object

dimensions = {400, 400}
camera = Camera::Perspective.new(
  look_from: Point.new(278.0, 278.0, -800.0),
  look_at: Point.new(278.0, 278.0, 0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

raytracer = Raytracer::Simple.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights),
  samples: 50
)

raytracer.render("cornell.png")
