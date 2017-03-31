require "../src/raytracer"

hitables = [] of Hitable

mat = MatteMaterial.new(Color.new(0.5, 0.5, 0.5))
# mat = MirrorMaterial.new(Color.new(0.5))

# File.read("data.csv").lines.each do |line|

buf = [] of Point

File.read("halverson.csv").lines.each do |line|
  values = line.split(",").map(&.to_f)
  buf << Point.new(values[0], values[2], values[1])
  if buf.size == 3
    hitables << Triangle.new(buf.pop, buf.pop, buf.pop, mat)
  end
end

puts "Parsed #{hitables.size} triangles"

light_color = Color.new(1.0, 1.0, 0.4) * 5.0

light_mat = DiffuseLightMaterial.new(light_color)
light_object = XZRect.new(
  Point.new(-100.0, 100.0, -100.0),
  Point.new(100.0, 100.0, 100.0),
  light_mat
)
light_object.flip!
light_light = AreaLight.new(light_object, light_color).as(Light)
light_object.area_light = light_light

hitables << light_object

scene = Scene.new(
  hitables,
  [light_light] of Light,
  # SkyBackground.new
  ConstantBackground.new(Color.from_hex("#ffffff") * 0.01) # background: CubeMap.new("cube_maps/Yokohama")

)

width, height = {800, 800}

camera = PerspectiveCamera.new(
  # look_from: Point.new(1.0, 1.0, 1.0).normalize * 10.0,
  look_from: Point.new(1.0, 1.0, 1.0).normalize * 20.0,
  look_at: Point.new(0.0, 1.5, 0.0),
  vertical_fov: 45.0,
  dimensions: {width, height}
)

# raytracer = WhittedRaytracer.new(
raytracer = SimpleRaytracer.new(
  # raytracer = NormalRaytracer.new(
  width, height,
  scene: scene,
  camera: camera,
  samples: 200
)

raytracer.recursion_depth = 5

raytracer.render("attractor.png", adaptive: false)
