class CosinePDF < PDF
  getter uvw : ONB

  def initialize(w)
    @uvw = ONB.from_w(w)
  end

  def value(direction)
    cosine = direction.normalize.dot(@uvw.w.normalize)

    if cosine > 0.0
      cosine / Math::PI
    else
      0.0
    end
  end

  def generate
    @uvw.local(random_cosine_direction)
  end
end
