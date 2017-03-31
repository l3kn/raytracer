require "csv"
require "../../raytracer"
require "./gen"

dimensions = {400, 400}
camera = PerspectiveCamera.new(
  look_from: Point.new(0.5, 2.5, 0.5),
  look_at: Point.new(0.5, 0.0, 0.5),
  up: Vector.x,
  vertical_fov: 20.0,
  dimensions: dimensions
)

# 100.times do |t|
  t = 0
  heightfield = [] of Array(Float64)

  # w1 = Wave.new(6.0, 1.0, 1.0, Vector2.new(0.5, 1.0), 2.0)
  # w2 = Wave.new(4.0, 1.0, 1.0, Vector2.new(1.0, 0.0), 2.0)
  # w3 = Wave.new(8.0, 0.5, 0.2, Vector2.new(1.0, 1.0), 2.0)
  w1 = CircularWave.new(1.0, 0.1, 1.0, Vector2.new(5.0, 5.0), 1.0).as(Wave)
  w = Waves.new([w1])

  # Range: (0, 0) ... (10, 10)
  resolution = 1000
  scale = 10.0 / resolution
  max_height = -Float64::MAX

  (0...resolution).each do |y_|
    row = [] of Float64
    (0...resolution).each do |x_|
      x = x_ * scale
      y = y_ * scale
      z = w.height(Vector2.new(x.to_f, y.to_f), t * 0.1)
      max_height = {z.abs, max_height}.max

      row << z
    end
    heightfield << row
  end

  mat = MatteMaterial.new(GridTexture.new(0.05, 0.01, 0.1))

  hitables = [] of Hitable

  scale_y = 1.0 / heightfield.size
  scale_x = 1.0 / heightfield[0].size
  scale_z = 0.2 / max_height

  (0...heightfield.size).each_cons(2) do |ys|
    (0...heightfield[0].size).each_cons(2) do |xs|
      y1, y2 = ys
      x1, x2 = xs

      z11, z12 = heightfield[y1][x1], heightfield[y2][x1]
      z21, z22 = heightfield[y1][x2], heightfield[y2][x2]

      p11 = Point.new(x1 * scale_x, z11 * scale_z, y1 * scale_y)
      p12 = Point.new(x1 * scale_x, z12 * scale_z, y2 * scale_y)
      p21 = Point.new(x2 * scale_x, z21 * scale_z, y1 * scale_y)
      p22 = Point.new(x2 * scale_x, z22 * scale_z, y2 * scale_y)

      hitables << Triangle.new(p11, p12, p22, mat)
      hitables << Triangle.new(p11, p22, p21, mat)
    end
  end

  lights = [] of Light

  # raytracer = SimpleRaytracer.new(
  raytracer = ColorRaytracer.new(
    dimensions, camera,
    scene: Scene.new(hitables, lights, ConstantBackground.new(Color::BLACK)),
    samples: 50
  )

  raytracer.render("heightfield#{t.to_s.rjust(3, '0')}.png")
# end
