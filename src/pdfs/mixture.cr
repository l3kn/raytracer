require "../pdf"

class MixturePDF < PDF
  getter p1 : PDF
  getter p2 : PDF

  def initialize(@p1, @p2)
  end

  def value(direction)
    @p1.value(direction) * 0.5 + @p2.value(direction) * 0.5
  end

  def generate
    if pos_random < 0.5
      @p1.generate
    else
      @p2.generate
    end
  end
end
