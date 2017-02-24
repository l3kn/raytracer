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

