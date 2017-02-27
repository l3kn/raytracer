struct Color
  COMPONENTS = [:r, :g, :b]
  define_vector
  define_op(:**)
  define_vector_op(:*)

  WHITE = self.new(1.0)
  BLACK = self.new(0.0)

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

  def black?
    @r == 0.0 && @g == 0.0 && @b == 0.0
  end

  def max
    {@r, @g, @b}.max
  end

  def inspect
    "Color(#{r.round(2)}, #{g.round(2)}, #{b.round(2)})"
  end

  def to_rgba(gamma_correction = 1.0)
    col = self.min(1.0) ** gamma_correction
    StumpyPNG::RGBA.new(
      (UInt16::MAX * col.r).to_u16,
      (UInt16::MAX * col.g).to_u16,
      (UInt16::MAX * col.b).to_u16,
      UInt16::MAX
    )
  end
end
