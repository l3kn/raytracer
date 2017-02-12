require "../src/raytracer"
require "../src/backgrounds/*"

hitables = [] of Hitable

hitables.push(Sphere.new(
  Point.new(0.0, -100.5, -1.0),
  100.0,
  MirrorMaterial.new(Color.new(0.8))
))

hitables.push(Sphere.new(
  Point.new(0.0, 0.0, -1.0),
  0.5,
  MatteMaterial.new(Color.new(0.1, 0.2, 0.5))
))

hitables.push(Sphere.new(
  Point.new(1.0, 0.0, -1.0),
  0.5,
  MirrorMaterial.new(Color.new(0.8, 0.6, 0.2))
))

hitables.push(Sphere.new(
  Point.new(-1.0, 0.0, -1.0),
  0.5,
  GlassMaterial.new(Color::WHITE, Color::WHITE, 1.8)
))

# light = XZRect.new(Point.new(-1000.0, 100.0, -1000.0),
#         Point.new(1000.0, 100.0, 1000.0),
#         DiffuseLight.new(ConstantTexture.new(Color::WHITE * 0.9)))
# light.flip!

# hitables.push(light)

scene = Scene.new(
  hitables,
  [
    # PointLight.new(Point.new(10.0), Color.new(200.0)).as(Light),
    # PointLight.new(Point.new(-10.0, 10.0, 10.0), Color.new(200.0)).as(Light),
    # PointLight.new(Point.new(-10.0, 10.0, -10.0), Color.new(200.0)).as(Light),
    # PointLight.new(Point.new(10.0, 10.0, -10.0), Color.new(200.0)).as(Light),
    # SpotLight.new(Point.new(0.0, 10.0, 0.0), Color.new(200.0), 0.2, 0.01).as(Light)
    # ObjectLight.new(light, Color.new(1.0)).as(Light)
  ] of Light,
  SkyBackground.new
)

width, height = {800, 400}

camera = PerspectiveCamera.new(
  look_from: Point.new(-1.5, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 30.0,
  dimensions: {width, height}
)
# raytracer = WhittedRaytracer.new(width, height,
raytracer = SimpleRaytracer.new(width, height,
                                scene: scene,
                                camera: camera,
                                samples: 100)

raytracer.recursion_depth = 5
raytracer.render("benchmark.png")
