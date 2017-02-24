class Wireframe
  property width : Int32
  property height : Int32
  property camera : PerspectiveCamera
  property triangles : Array(Triangle)

  def initialize(@width, @height, @camera, @triangles)
  end

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
