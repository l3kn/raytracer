require "./helper"

# Source: http://flafla2.github.io/2014/08/09/perlinnoise.html

class Perlin
  def initialize(@repeat = 0)
    # This way we don't need to "& 255" array indices later
    @p = [] of Int32
    @p = (0..256).to_a.shuffle * 2
  end

  # TODO: Make this work for negative x,y,z, too
  def perlin(point)
    x, y, z = point.tuple

    if @repeat > 0
      x %= @repeat
      y %= @repeat
      z %= @repeat
    end

    xi = x.to_i & 255
    yi = y.to_i & 255
    zi = z.to_i & 255

    xf = x - x.to_i
    yf = y - y.to_i
    zf = z - z.to_i

    u = fade(xf)
    v = fade(yf)
    w = fade(zf)

    aaa = @p[@p[@p[    xi ] +     yi ] +     zi ]
    aab = @p[@p[@p[    xi ] +     yi ] + inc(zi)]
    aba = @p[@p[@p[    xi ] + inc(yi)] +     zi ]
    abb = @p[@p[@p[    xi ] + inc(yi)] + inc(zi)]
    baa = @p[@p[@p[inc(xi)] +     yi ] +     zi ]
    bab = @p[@p[@p[inc(xi)] +     yi ] + inc(zi)]
    bba = @p[@p[@p[inc(xi)] + inc(yi)] +     zi ]
    bbb = @p[@p[@p[inc(xi)] + inc(yi)] + inc(zi)]

    x1 = mix(grad(baa, xf-1, yf, zf),
             grad(aaa, xf,   yf, zf),
             u)

    x2 = mix(grad(bba, xf-1, yf-1, zf),
             grad(aba, xf,   yf-1, zf),
             u)

    y1 = mix(x2, x1, v)

    x1 = mix(grad(bab, xf-1, yf, zf-1),
             grad(aab, xf,   yf, zf-1),
             u)

    x2 = mix(grad(bbb, xf-1, yf-1, zf-1),
             grad(abb, xf,   yf-1, zf-1),
             u)

    y2 = mix(x2, x1, v)

    res = (mix(y2, y1, w) + 1) / 2
    res
  end

  def octave_perlin(point, octaves, persistence)
    total = 0.0
    frequency = 1.0
    amplitude = 1.0
    max_value = 0.0

    (0...octaves).each do |i|
      total += perlin(point * frequency) * amplitude
      max_value += amplitude
      amplitude *= persistence
      frequency *= 2
    end

    total / max_value
  end

  def fade(t)
    t * t * t * (t * (t * 6 - 15) + 10)
  end

  def inc(n)
    @repeat > 0 ? ((n + 1) % @repeat) : (n + 1)
  end

  # Generate random vector
  # to one of the edges
  def grad(hash, x, y, z)
    case hash & 0xF
    when 0x0;  x + y
    when 0x1; -x + y
    when 0x2;  x - y
    when 0x3; -x - y
    when 0x4;  x + z
    when 0x5; -x + z
    when 0x6;  x - z
    when 0x7; -x - z
    when 0x8;  y + z
    when 0x9; -y + z
    when 0xA;  y - z
    when 0xB; -y - z
    when 0xC;  y + x
    when 0xD; -y + z
    when 0xE;  y - x
    when 0xF; -y - z
    else; 0.0
    end
  end
end
