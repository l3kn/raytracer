require "../pdf"
require "../hitable"

class HitablePDF < PDF
  getter hitable : Hitable
  getter origin : Vec3

  def initialize(@hitable, @origin)
  end

  def value(direction)
    hitable.pdf_value(@origin, direction)
  end

  def generate
    hitable.random(@origin)
  end
end
