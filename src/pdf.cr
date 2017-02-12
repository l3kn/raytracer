require "./hitable"
require "./onb"

abstract class PDF
  abstract def value(direction : Vector)
  abstract def generate : Vector
end

class HitablePDF < PDF
  getter hitable : Hitable
  getter origin : Point

  def initialize(@hitable, @origin)
  end

  def value(direction)
    hitable.pdf_value(@origin, direction)
  end

  def generate
    hitable.random(@origin)
  end
end

class CosinePDF < PDF
  getter uvw : ONB

  def initialize(w)
    @uvw = ONB.from_w(w)
  end

  def value(direction)
    cosine = direction.normalize.dot(@uvw.w.normalize)
    (cosine > 0.0) ? (cosine * INV_PI) : 0.0
  end

  def generate
    @uvw.local(random_cosine_direction)
  end
end

class MixturePDF < PDF
  getter p1 : PDF
  getter p2 : PDF

  def initialize(@p1, @p2)
  end

  def value(direction)
    @p1.value(direction) * 0.5 + @p2.value(direction) * 0.5
  end

  def generate
    pos_random < 0.5 ? @p1.generate : @p2.generate
  end
end
