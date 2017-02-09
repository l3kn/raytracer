require "../src/raytracer"
require "../src/backgrounds/*"

hitables = [] of Hitable

hitables.push(Sphere.new(
  Point.new(0.0, -100.5, -1.0),
  100.0,
  # Metal.new(Color.new(0.8), 0.0)
  BSDFMaterial.new(BSDF.new([
    SpecularReflection.new(Color.new(0.8), FConductor.new(0.0, 1.0)).as(BxDF)
  ]))
))

hitables.push(Sphere.new(
  Point.new(0.0, 0.0, -1.0),
  0.5,
  # Lambertian.new(Color.new(0.1, 0.2, 0.5))
  BSDFMaterial.new(BSDF.new([
    LambertianReflection.new(Color.new(0.1, 0.2, 0.5)).as(BxDF)
    # SpecularReflection.new(Color.new(0.8), FConductor.new(0.0, 1.0)).as(BxDF)
  ]))
))

hitables.push(Sphere.new(
  Point.new(1.0, 0.0, -1.0),
  0.5,
  BSDFMaterial.new(BSDF.new([
    SpecularReflection.new(Color.new(0.8, 0.6, 0.2), FConductor.new(0.0, 1.0)).as(BxDF)
  ]))
  # Metal.new(Color.new(0.8, 0.6, 0.2), 0.0)
))

hitables.push(Sphere.new(
  Point.new(-1.0, 0.0, -1.0),
  0.5,
  # Dielectric.new(1.8)
  BSDFMaterial.new(BSDF.new([
    SpecularTransmission.new(Color.new(1.0), 1.0, 1.0).as(BxDF)
  ]))
))

scene = Scene.new(
  hitables,
  [
    PointLight.new(Point.new(10.0), Color.new(200.0)).as(Light),
    # SpotLight.new(Point.new(0.0, 10.0, 0.0), Color.new(200.0), 0.2, 0.01).as(Light)
  ],
  ConstantBackground.new(Color::BLACK)
  # SkyBackground.new
)

width, height = {800, 400}
# width, height = {400, 200}

camera = PerspectiveCamera.new(
  look_from: Point.new(-1.5, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 30.0,
  dimensions: {width, height}
)

raytracer = IntegratorRaytracer.new(width, height, camera: camera, samples: 2, scene: scene)
raytracer.render("benchmark.png")
