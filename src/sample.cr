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
