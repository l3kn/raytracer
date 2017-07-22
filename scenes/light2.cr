require "../raytracer"

hitables = [] of UnboundedHitable
lights = [] of Light

hitables << TransformationWrapper.new(
  Sphere.new(Material::Matte.new(Color.new(0.8))),
  VS.new(Vector.new(0.0, -100.5, -1.0), 100.0)
)

ior = 1.8

hitables << TransformationWrapper.new(
  Sphere.new(Material::Glass.new(ior)),
  VS.new(Vector.new(-1.0, -0.0, -1.0), 0.5)
)
hitables << TransformationWrapper.new(
  Sphere.new(Material::Glass.new(ior)),
  VS.new(Vector.new(0.0, -0.0, -1.0), 0.5)
)
hitables << TransformationWrapper.new(
  Sphere.new(Material::Glass.new(ior)),
  VS.new(Vector.new(1.0, -0.0, -1.0), 0.5)
)

red = Color.new(20.0, 0.0, 0.0)
green = Color.new(0.0, 20.0, 0.0)
blue = Color.new(0.0, 0.0, 20.0)

height = 2.0
size = 0.4

light1_obj, light1_light = Light::Area.with_object(
  XZRect.new(
    Point.new(-1.0 - size, height, -1.0 - size),
    Point.new(-1.0 + size, height, -1.0 + size),
    Material::DiffuseLight.new(red)
  ).flip!,
  red
)

light2_obj, light2_light = Light::Area.with_object(
  XZRect.new(
    Point.new(0.0 - size, height, -1.0 - size),
    Point.new(0.0 + size, height, -1.0 + size),
    Material::DiffuseLight.new(green)
  ).flip!,
  green
)

light3_obj, light3_light = Light::Area.with_object(
  XZRect.new(
    Point.new(1.0 - size, height, -1.0 - size),
    Point.new(1.0 + size, height, -1.0 + size),
    Material::DiffuseLight.new(blue)
  ).flip!,
  blue
)

lights += [light1_light, light2_light, light3_light]
hitables += [light1_obj, light2_obj, light3_obj]

dimensions = {800, 400}

camera = Camera::Perspective.new(
  look_from: Point.new(0.0, 1.5, 1.5),
  look_at: Point.new(0.0, 0.0, -1.0),
  vertical_fov: 35.0,
  dimensions: dimensions
)

raytracer = Raytracer::Path.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights),
  samples: 100
)

# This scene is very small
# so a smaller serach radius will be much faster
# raytracer.initial_search_radius = 0.01
raytracer.recursion_depth = 5
raytracer.render("light2.png")
