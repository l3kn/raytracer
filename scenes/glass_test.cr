require "../raytracer"

hitables = [] of Hitable
lights = [] of Light

# [-1, 0].each do |x|
#   [-1, 0].each do |y|
#     [-1, 0].each do |z|
#       hitables << Cuboid.new(
#         Point.new(x.to_f, y.to_f, z.to_f),
#         Point.new(x.to_f, y.to_f, z.to_f) + Vector.one,
#         GlassMaterial.new(1.4)
#       )
#     end
#   end
# end

x, y, z = -1, -1, -1

hitables << Cuboid.new(
  Point.new(x.to_f, y.to_f, z.to_f),
  Point.new(x.to_f, y.to_f, z.to_f) + Vector.one * 2.0,
  GlassMaterial.new(1.4)
)

dimensions = {800, 800}
camera = PerspectiveCamera.new(
  look_from: Point.new(2.0, 2.0, 2.0),
  look_at: Point.new(0.0),
  vertical_fov: 40.0,
  dimensions: dimensions
)

raytracer = Renderer::Path.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights, SkyBackground.new),
  samples: 100
)

raytracer.render("glass.png")
