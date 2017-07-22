require "../raytracer"

hitables = [] of UnboundedHitable

File.read("blocks3.csv").each_line do |line|
  tokens = line.split(",")

  x = tokens.shift.to_f
  # y = 16 - tokens.shift.to_f
  y = tokens.shift.to_f
  z = tokens.shift.to_f

  sx = tokens.shift.to_f
  sy = tokens.shift.to_f
  sz = tokens.shift.to_f

  color = Color.new(tokens.shift.to_f, tokens.shift.to_f, tokens.shift.to_f)
  opaque = tokens.shift == "true"

  # TODO: is the offset necessary?
  hitables << Cuboid2.new(
    Point.new(x, y, z),
    Point.new(x + sx, y + sy, z + sz) - Vector.one * (EPSILON * 10),
    opaque ? Material::Matte.new(color) : Material::Glass.new(1.4, color, color)
  )
end

dimensions = {800, 800}

camera = Camera::Perspective.new(
  look_from: Point.new(-20.0, 80.0, -10.0),
  look_at: Point.new(128.0, 0.0, 128.0),
  vertical_fov: 40.0,
  dimensions: dimensions,
  aperture: 2.0
)

raytracer = Raytracer::Simple.new(
  dimensions, camera,
  scene: Scene.new(hitables, background: Background::Sky.new),
  samples: 100
)

raytracer.render("iso.png")
