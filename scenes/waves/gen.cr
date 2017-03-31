struct Vector2 < LA::AVector2
end

abstract class Wave
  @wavelength : Float64
  @amplitude : Float64
  @speed : Float64
  @frequency : Float64
  @k : Float64
  @phase : Float64

  def initialize(@wavelength, @amplitude, @speed, @k = 1)
    @phase = @speed * @wavelength * 0.5
    @frequency = 2.0 / @wavelength
  end

  abstract def height(point : Vector2, t) : Float64
end

class DirectionalWave < Wave
  @direction : Vector2

  def initialize(wavelength, amplitude, speed, @direction, k = 1)
    super(wavelength, amplitude, speed, k)
  end

  def height(point : Vector2, t)
    2 * @amplitude *
      (Math.sin(@direction.dot(point) * @frequency + t * @phase) / 2.0) ** @k
  end
end

class CircularWave < Wave
  @center : Vector2

  def initialize(wavelength, amplitude, speed, @center, k = 1)
    super(wavelength, amplitude, speed, k)
  end

  def height(point : Vector2, t)
    x = (point - @center).length
    2 * @amplitude *
      (Math.sin(x * @frequency + t * @phase) / 2.0) ** @k
  end
end

class Waves
  @waves : Array(Wave)

  def initialize(@waves)
  end

  def height(point : Vector2, t)
    res = 0.0
    @waves.each do |w|
      res += w.height(point, t)
    end
    res
  end

  def heights(width : Float64, height : Float64, step : Float64, t)
    rows = [] of Array(Point)
    (0...(height / step).to_i).each do |y_|
      y = y_ * step
      row = [] of Point
      (0...(width / step).to_i).each do |x_|
        x = x_ * step
        height = height(Vector2.new(x, y), t)
        row << Point.new(x, height, y)
      end
      rows << row
    end

    rows
  end
end

