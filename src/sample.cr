abstract class Filter
  property width_x : Float64
  property width_y : Float64

  def initialize(width = 1.0)
    @width_x = @width_y = width
  end

  abstract def evaluate(x : Float64, y : Float64) : Float64
end

class BoxFilter < Filter
  def evaluate(x, y)
    1.0
  end
end

class TriangleFilter < Filter
  def evaluate(x, y)
    (@width_x - x.abs) * (@width_y - y.abs)
  end
end

class GaussianFilter < Filter
  @exp_x : Float64
  @exp_y : Float64

  def initialize(width, @alpha = 2.0)
    super(width)
    @exp_x = Math.exp(-@alpha*@width_x*@width_x)
    @exp_y = Math.exp(-@alpha*@width_y*@width_y)
  end

  def evaluate(x, y)
    gaussian(x, @exp_x) * gaussian(y, @exp_y)
  end

  def gaussian(d, expv)
    Math.exp(-@alpha * d * d) - expv
  end
end

class MitchellFilter
  @inv_width_x : Float64
  @inv_width_y : Float64

  def initialize(width, @b : Float64 = 1.0 / 3, @c : Float64 = 1.0 / 3)
    super(width)
    @inv_width_x = 1.0 / @width_x
    @inv_width_y = 1.0 / @width_y
  end

  def evaluate(x, y)
    mitchell(x * @inv_width_x) * mitchell(y * @inv_width_y)
  end

  def mitchell(x)
    x = (x * 2).abs
    if x > 1.0
      ((-@b - 6.0*@c) * x*x*x + (6.0*@b + 20.0*@c) * x*x +
       (-12.0*@b -48.0*@c) * x + (8.0*@b + 24.0*@c)) * (1.0 / 6.0)
    else
      ((10.0 - 9.0*@b - 6.0*@c) * x*x*x +
       (-18.0 + 12.0*@b + 6.0*@c) +
       (6.0 - 2.0*@b)) * (1.0 / 6.0)
    end
  end
end

class Sample
  getter sum_weights : Float64
  getter mean : Color
  getter n_variance : Color

  def initialize
    @sum_weights = 0.0
    @mean = Color::BLACK
    @n_variance = Color::BLACK
  end

  def add(sample : Color, weight = 1.0)
    @sum_weights += weight
    new_mean = @mean + (sample - @mean)*(weight / @sum_weights)
    # new_n_var = @n_variance + (sample - @mean) * (sample - new_mean)

    @mean = new_mean
    # TODO: Support variance
    # @n_variance = new_n_var
  end

  def variance
    @n_variance
    # @n_variance / @n.to_f
  end
end

class Visualisation
  def initialize(@width : Int32, @height : Int32)
    @layers = {} of Symbol => Array(Float64)
    @max = {} of Symbol => Float64
  end

  def add_layer(name : Symbol)
    @layers[name] = Array(Float64).new(@width * @height, 0.0)
    @max[name] = Float64::MIN
  end

  def set(name : Symbol, x : Int32, y : Int32, value : Float64)
    @layers[name][@width * y + x] = value
    @max[name] = max(@max[name], value)
  end

  def write(name : Symbol, filename : String)
    canvas = StumpyPNG::Canvas.new(@width, @height + 16) do |x, y|
      if y < @height
        value = @layers[name][@width * y + x] / @max[name]
        StumpyPNG::RGBA.from_relative(
          value,
          value,
          value,
          1.0
        )
      else
        StumpyPNG::RGBA.from_hex("#ffffff")
      end
    end

    StumpyUtils.text(canvas, 16, @height,
                     "#{name.to_s} (max: #{@max[name].round(2)})",
                     StumpyPNG::RGBA.from_hex("#000000"),
                     StumpyPNG::RGBA.from_hex("#ffffff"),
                     size: 2)
    StumpyPNG.write(canvas, filename)
  end
end

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
    puts ({x0, y0})
    puts ({x1, y1})
    StumpyUtils.line(canvas, x0, y0, x1, y1, color)
  end
end
