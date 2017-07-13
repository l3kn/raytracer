require "../raytracer"

white = MatteMaterial.new(Color.new(0.73))
red = MatteMaterial.new(Color.new(0.65, 0.05, 0.05))
green = MatteMaterial.new(Color.new(0.12, 0.45, 0.15))
aluminum = MirrorMaterial.new(Color.new(0.8, 0.85, 0.88))

lbf = Point.new(0.0, 0.0, 0.0)       # Left | Bottom | Front
rtb = Point.new(555.0, 555.0, 555.0) # Right | Top | Back

hitables = [] of Hitable
lights = [] of Light
hitables << XZRect.new(lbf, Point.new(555.0, 0.0, 555.0), white)
hitables << YZRect.new(lbf, Point.new(0.0, 555.0, 555.0), red)
hitables << YZRect.new(Point.new(555.0, 0.0, 0.0), rtb, green).flip!
hitables << XZRect.new(Point.new(0.0, 555.0, 0.0), rtb, white).flip!
hitables << XYRect.new(Point.new(0.0, 0.0, 555.0), rtb, white).flip!


hitables << TransformationWrapper.new(
  Cuboid.new(Point.new(0.0), Point.new(165.0, 330.0, 165.0), aluminum),
  # Cuboid.new(Point.new(0.0), Point.new(165.0, 330.0, 165.0), GlassMaterial.new(1.5)),
  VQS.new(Vector.new(265.0, 0.0, 295.0), 1.0, Vector.y, 15.0)
)

hitables << TransformationWrapper.new(
  Sphere.new(GlassMaterial.new(1.5)),
  VS.new(Vector.new(190.0, 90.0, 190.0), 90.0)
)

light_object, light_light = AreaLight.with_object(
  XZRect.new(
    Point.new(213.0, 554.0, 227.0),
    Point.new(343.0, 554.0, 332.0),
    DiffuseLightMaterial.new(Color.new(15.0))
  ).flip!,
  Color.new(15.0)
)

lights << light_light
hitables << light_object

dimensions = {300, 300}
camera = PerspectiveCamera.new(
  look_from: Point.new(278.0, 278.0, -800.0),
  look_at: Point.new(278.0, 278.0, 0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

# raytracer = SPPMRaytracer.new(
# raytracer = WhittedRaytracer.new(
raytracer = SimpleRaytracer.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights),
  # samples: 10 # 200
  samples: 100
)

raytracer.render("cornell.png")
