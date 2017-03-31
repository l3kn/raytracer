require "csv"
require "../../raytracer"
require "./gen"

dimensions = {400, 400}
camera = PerspectiveCamera.new(
  look_from: Point.new(8.0, 6.0, 8.0),
  look_at: Point.new(5.0, 0.0, 5.0),
  vertical_fov: 60.0,
  dimensions: dimensions
)
# mat = MatteMaterial.new(GridTexture.new(2.0, 0.4, 0.02))
mat = GlassMaterial.new(
  1.33,
  Color.new(0.5, 0.7, 0.8),
  Color.new(0.5, 0.7, 0.8)
)

w1 = DirectionalWave.new(1.0, 1.0, 1.0, Vector2.new(0.5, 1.0), 1.0).as(Wave)
# w2 = Wave.new(4.0, 1.0, 1.0, Vector2.new(1.0, 0.0), 2.0)
# w3 = Wave.new(8.0, 0.5, 0.2, Vector2.new(1.0, 1.0), 2.0)
# w1 = CircularWave.new(2.0, 1.0, 1.0, Vector2.new(5.0, 5.0), 1.0).as(Wave)
w = Waves.new([w1])


height = 10.0
width = 10.0
heightfield = w.heights(width, height, 0.5, 0.0)

surface = [] of Hitable

(0...heightfield.size).each_cons(2) do |ys|
  (0...heightfield[0].size).each_cons(2) do |xs|
    y1, y2 = ys
    x1, x2 = xs
    p11, p12 = heightfield[y1][x1], heightfield[y2][x1]
    p21, p22 = heightfield[y1][x2], heightfield[y2][x2]

    surface << Triangle.new(p11, p12, p22, mat)
    surface << Triangle.new(p11, p22, p21, mat)
  end
end

sides = [] of Hitable

depth = 3.0

# TODO: fix all normals
(0...heightfield[0].size).each_cons(2) do |xs|
  x1, x2 = xs
  p12, p22 = heightfield[0][x1], heightfield[0][x2]
  p11 = Point.new(p12.x, -depth, p12.z)
  p21 = Point.new(p22.x, -depth, p22.z)

  sides << Triangle.new(p11, p12, p22, mat)
  sides << Triangle.new(p11, p22, p21, mat)
end

(0...heightfield[0].size).each_cons(2) do |xs|
  x1, x2 = xs
  p12, p22 = heightfield[-1][x1], heightfield[-1][x2]
  p11 = Point.new(p12.x, -depth, p12.z)
  p21 = Point.new(p22.x, -depth, p22.z)

  sides << Triangle.new(p11, p12, p22, mat).flip!
  sides << Triangle.new(p11, p22, p21, mat).flip!
end

(0...heightfield.size).each_cons(2) do |ys|
  y1, y2 = ys
  p12, p22 = heightfield[y1][0], heightfield[y2][0]
  p11 = Point.new(p12.x, -depth, p12.z)
  p21 = Point.new(p22.x, -depth, p22.z)

  sides << Triangle.new(p11, p12, p22, mat)
  sides << Triangle.new(p11, p22, p21, mat)
end

(0...heightfield.size).each_cons(2) do |ys|
  y1, y2 = ys
  p12, p22 = heightfield[y1][-1], heightfield[y2][-1]
  p11 = Point.new(p12.x, -depth, p12.z)
  p21 = Point.new(p22.x, -depth, p22.z)

  sides << Triangle.new(p11, p12, p22, mat).flip!
  sides << Triangle.new(p11, p22, p21, mat).flip!
end

floor = [] of Hitable
p11 = Point.new(0.0, -depth, 0.0)
p12 = Point.new(0.0, -depth, height)
p21 = Point.new(width, -depth, 0.0)
p22 = Point.new(width, -depth, height)
floor << Triangle.new(p11, p12, p22, mat)
floor << Triangle.new(p11, p22, p21, mat)

hitables = [] of Hitable
hitables += surface
hitables += sides
# hitables += floor

hitables << XZRect.new(
  Point.new(-20.0, -depth, -20.0),
  Point.new(20.0, -depth, 20.0),
  MatteMaterial.new(
    GridTexture.new(2.0, 0.4, 0.02)
  )
)

lights = [] of Light

raytracer = SimpleRaytracer.new(
# raytracer = ColorRaytracer.new(
  dimensions, camera,
  scene: Scene.new(hitables, lights, SkyBackground.new),
  samples: 200
)

raytracer.render("block.png")
