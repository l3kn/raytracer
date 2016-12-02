require "./vector"

struct ONB
  getter u : Vector, v : Vector, w : Vector

  def initialize(@u, @v, @w)
  end

  def local(vec)
    u * vec.x + v * vec.y + w * vec.z
  end

  def self.from_w(n)
    w = n.normalize.to_vector
    a = w.x.abs > 0.9 ? Vector.y : Vector.x

    v = w.cross(a).normalize
    u = w.cross(v)

    ONB.new(u, v, w)
  end
end
