require "../src/raytracer"
require "../src/transformation"

white = MatteMaterial.new(Color.new(0.73))
red = MatteMaterial.new(Color.new(0.65, 0.05, 0.05))
green = MatteMaterial.new(Color.new(0.12, 0.45, 0.15))
aluminum = MirrorMaterial.new(Color.new(0.8, 0.85, 0.88))

left = YZRect.new(
  Point.new(555.0, 0.0, 0.0),
  Point.new(555.0, 555.0, 555.0),
  green
)
left.flip!

right = YZRect.new(
  Point.new(0.0, 0.0, 0.0),
  Point.new(0.0, 555.0, 555.0),
  red
)

bottom = XZRect.new(
  Point.new(0.0, 0.0, 0.0),
  Point.new(555.0, 0.0, 555.0),
  white
)

top = XZRect.new(
  Point.new(0.0, 555.0, 0.0),
  Point.new(555.0, 555.0, 555.0),
  white
)
top.flip!

back = XYRect.new(
  Point.new(0.0, 0.0, 555.0),
  Point.new(555.0, 555.0, 555.0),
  white)
back.flip!

cube2 = TransformationWrapper.new(
    Cuboid.new(Point.new(0.0), Point.new(165.0, 330.0, 165.0), aluminum),
    VQS.new(Vector.new(265.0, 0.0, 295.0), 1.0, Vector.y, 15.0)
)

sphere = TransformationWrapper.new(
  Sphere.new(GlassMaterial.new(Color::WHITE, Color::WHITE, 1.5)),
  VS.new(Vector.new(190.0, 90.0, 190.0), 90.0)
)

light_mat = DiffuseLightMaterial.new(Color.new(15.0))

light_object = XZRect.new(Point.new(213.0, 554.0, 227.0),
  Point.new(343.0, 554.0, 332.0),
  light_mat)
light_object.flip!

light_light = AreaLight.new(light_object, Color.new(15.0)).as(Light)
light_hitable = LightHitable.new(light_object, light_light)

width, height = {400, 400}

scene = Scene.new(
  [left, right, bottom, top, back, sphere, cube2, light_hitable].map(&.as(Hitable)),
  # [left, right, bottom, top, back, light_hitable].map(&.as(Hitable)),
  [light_light],
  ConstantBackground.new(Color.new(0.0))
)

camera = PerspectiveCamera.new(
  look_from: Point.new(278.0, 278.0, -800.0),
  look_at: Point.new(278.0, 278.0, 0.0),
  vertical_fov: 40.0,
  dimensions: {width, height}
)

# raytracer = SimpleRaytracer.new(
raytracer = PathRaytracer.new(
# raytracer = DirectLightingRaytracer.new(
  width, height,
  scene: scene,
  camera: camera,
  samples: 200,
)

raytracer.recursion_depth = 5
raytracer.render("cornell.png", adaptive: false)

# f = Point.new(278.0, 278.0, -800.0)
# a = Point.new(278.0, 0.0, 278.0)

# puts raytracer.cast_ray(
#   Ray.new(
#     f,
#     (a - f).normalize
#   )
# )
