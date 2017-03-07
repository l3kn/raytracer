require "../../src/raytracer"
require "../../src/backgrounds/*"
require "../../src/transformation"

class Turtle
  property position : Point
  property lines : Array(FiniteHitable)
  property thickness : Float64
  property material : Material
  property transformation : Transformation
  property transformation2 : Transformation

  def initialize
    @position = Point.new(0.0)
    @transformation = Transformation::ID
    @transformation2 = Transformation::ID
    @lines = [] of FiniteHitable
    @thickness = 0.2
    # @material = Lambertian.new(Color.new(0.1, 0.2, 0.5))
    @material = Metal.new(Color.new(0.8, 0.6, 0.2), 0.0)

    @lines << Sphere.new(
      Point.new(0.0),
      @thickness,
      @material
    )
  end

  def forward(n)
    line = Cylinder.new(
      0.0, n, @thickness, @material
    )
    @lines << TransformationWrapper.new(line, @transformation * Transformation.translation(@position))

    cap = Sphere.new(
      Point.new(0.0, n, 0.0),
      @thickness,
      @material
    )
    @lines << TransformationWrapper.new(cap, @transformation * Transformation.translation(@position))

    @position += @transformation.object_to_world(Vector.new(0.0, -n, 0.0))
  end

  def rotate_x(n)
    @transformation = @transformation * Transformation.rotation_x(n)
  end

  def rotate_y(n)
    p @transformation
    @transformation = @transformation * Transformation.rotation_y(n)
    p @transformation
  end

  def rotate_z(n)
    @transformation = @transformation * Transformation.rotation_z(n)
  end
end

class LSystem
  property start : String
  property rules : Hash(Char, String)

  def initialize(@start, @rules)
  end

  def step
    new = ""

    @start.chars.each do |char|
      if @rules.has_key?(char)
        new += @rules[char]
      else
        new += char
      end
    end

    @start = new
  end
end

triangle = LSystem.new(
  start: "X",
  # rules: {
  # 'A' => "+B-A-B+",
  # 'B' => "-A+B+A-"
  # }
  rules: {
    'X' => "^<XF^<XFX-F^>>XFX&F+>>XFX-F>X->" # 'X' => "^F+F+F^F^F"
  }
)

triangle.step
triangle.step
# triangle.step
# triangle.step

t = Turtle.new

triangle.start.chars.each do |char|
  case char
  when '^'
    t.rotate_z(-90.0)
  when '&'
    t.rotate_z(90.0)
  when '+'
    t.rotate_y(-90.0)
  when '-'
    t.rotate_y(90.0)
  when '>'
    t.rotate_x(-90.0)
  when '<'
    t.rotate_x(90.0)
  when 'F'
    t.forward(1.0)
  else
    puts "Unknown token: #{char}"
  end
end

width, height = {800, 400}

camera = Camera.new(
  look_from: Point.new(10.0),
  look_at: Point.new(0.0, 2.0, 0.0),
  vertical_fov: 30,
  aspect_ratio: width.to_f / height.to_f,
  aperture: 0.00
)

raytracer = NormalRaytracer.new(width, height,
  # hitables: BVHNode.new(t.lines),
  hitables: FiniteHitableList.new(t.lines),
  camera: camera,
  samples: 10,
  background: SkyBackground.new)

raytracer.render("turtle.png")
