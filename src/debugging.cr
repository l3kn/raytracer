require "stumpy_png"

class CameraCanvas
  getter canvas : StumpyPNG::Canvas
  getter camera : Camera

  def initialize(@camera, @canvas)
  end

  def initialize(@camera, width, height)
    @canvas = StumpyPNG::Canvas.new(width, height, StumpyPNG::RGBA.from_hex("#000000"))
  end

  def line(from : Point, to : Point, color = StumpyPNG::RGBA.from_hex("#00ff00"))
    x0, y0 = @camera.corresponding(from)
    x1, y1 = @camera.corresponding(to)
    StumpyUtils.line(canvas, x0, y0, x1, y1, color)
  end
end

class BoundingBoxDebugger
  getter canvas : CameraCanvas

  def initialize(@canvas)
  end

  def draw(hitable : BoundedHitable, color = StumpyPNG::RGBA.from_hex("#00ff00"), depth = 5)
    p0, p1 = hitable.bounding_box.min, hitable.bounding_box.max

    p000 = Point.new(p0.x, p0.y, p0.z)
    p001 = Point.new(p0.x, p0.y, p1.z)
    p010 = Point.new(p0.x, p1.y, p0.z)
    p011 = Point.new(p0.x, p1.y, p1.z)
    p100 = Point.new(p1.x, p0.y, p0.z)
    p101 = Point.new(p1.x, p0.y, p1.z)
    p110 = Point.new(p1.x, p1.y, p0.z)
    p111 = Point.new(p1.x, p1.y, p1.z)

    @canvas.line(p000, p001, color)
    @canvas.line(p000, p010, color)
    @canvas.line(p000, p100, color)
    @canvas.line(p001, p011, color)
    @canvas.line(p001, p101, color)
    @canvas.line(p010, p011, color)
    @canvas.line(p010, p110, color)
    @canvas.line(p011, p111, color)
    @canvas.line(p100, p110, color)
    @canvas.line(p100, p101, color)
    @canvas.line(p101, p111, color)
    @canvas.line(p110, p111, color)

    if hitable.is_a? BVHNode && depth > 0
      draw(hitable.left, StumpyPNG::RGBA.from_hex("#ff0000"), depth - 1)
      draw(hitable.right, StumpyPNG::RGBA.from_hex("#0000ff"), depth - 1)
    end
  end
end

class Wireframe
  property width : Int32
  property height : Int32
  property camera : PerspectiveCamera
  property triangles : Array(Triangle)

  def initialize(@width, @height, @camera, @triangles); end

  def render(canvas : StumpyPNG::Canvas)
    @triangles.each_with_index do |triangle, i|
      a_x, a_y = @camera.corresponding(triangle.a)
      b_x, b_y = @camera.corresponding(triangle.b)
      c_x, c_y = @camera.corresponding(triangle.c)

      StumpyUtils.line(canvas,
        a_x.to_i, a_y.to_i,
        b_x.to_i, b_y.to_i,
        StumpyPNG::RGBA.from_hex("#00ff00"))
      StumpyUtils.line(canvas,
        a_x.to_i, a_y.to_i,
        c_x.to_i, c_y.to_i,
        StumpyPNG::RGBA.from_hex("#00ff00"))
      StumpyUtils.line(canvas,
        b_x.to_i, b_y.to_i,
        c_x.to_i, c_y.to_i,
        StumpyPNG::RGBA.from_hex("#00ff00"))
    end
    canvas
  end

  def render(filename : String)
    canvas = StumpyPNG::Canvas.new(@width, @height, StumpyPNG::RGBA.from_hex("#000000"))
    render(canvas)
    StumpyPNG.write(canvas, filename)
  end
end
