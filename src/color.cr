struct Color
  WHITE = self.new(1.0)
  BLACK = self.new(0.0)

  getter r, g, b

  def initialize
    @r, @g, @b = 0.0, 0.0, 0.0
  end

  def initialize(value : Float64)
    @r, @g, @b = value, value, value
  end

  def initialize(@r : Float64, @g : Float64, @b : Float64)
  end

  def self.from_hex(hex)
    r = hex[1, 2].to_i(16).to_f / 255
    g = hex[3, 2].to_i(16).to_f / 255
    b = hex[5, 2].to_i(16).to_f / 255

    Color.new(r, g, b)
  end

  def mix(other : Color, t : Float64)
    Color.new(
      mix(@r, other.r, t),
      mix(@g, other.g, t),
      mix(@b, other.b, t),
    )
  end

  {% for op in %w(* **) %}
    def {{op.id}}(other : Float64)
      Color.new(@r {{op.id}} other, @g {{op.id}} other, @b {{op.id}} other)
    end
  {% end %}

  def /(other : Float64)
    inverse = 1.0 / other
    Color.new(@r * inverse, @g * inverse, @b * inverse)
  end

  {% for op in %w(* +) %}
    def {{op.id}}(other : Color)
      Color.new(@r {{op.id}} other.r, @g {{op.id}} other.g, @b {{op.id}} other.b)
    end
  {% end %}

  def de_nan
    (@r.nan? || @g.nan? || @b.nan?) ? Color::BLACK : self
  end

  def min(other : Float64)
    Color.new(
      min(@r, other),
      min(@g, other),
      min(@b, other)
    )
  end
end
