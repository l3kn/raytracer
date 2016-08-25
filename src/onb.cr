require "./vec3"

class ONB
  getter u : Vec3
  getter v : Vec3
  getter w : Vec3

  def initialize(@u, @v, @w)
  end

  def local(vec)
    u * vec.x + v * vec.y + w * vec.z
  end

  def self.from_w(n)
    w = n.normalize
    a = w.x.abs > 0.9 ? Vec3::Y : Vec3::X

    v = w.cross(a).normalize
    u = w.cross(v)

    ONB.new(u, v, w)
  end
end
