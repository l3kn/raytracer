struct Color
  COMPONENTS = [:r, :g, :b]
  define_vector

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

  define_op(:**)
  define_vector_op(:*)

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
    (@r < EPSILON) && (@g < EPSILON) && (@b < EPSILON)
  end
end
