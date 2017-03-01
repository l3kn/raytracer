struct ONB
  getter u : Vector, v : Vector, w : Vector
  def initialize(@u, @v, @w); end

  def world_to_local(vec)
    Vector.new(vec.dot(@u), vec.dot(@v), vec.dot(@w))
  end

  def local_to_world(vec)
    Vector.new(
      @u.x * vec.x + @v.x * vec.y + @w.x * vec.z,
      @u.y * vec.x + @v.y * vec.y + @w.y * vec.z,
      @u.z * vec.x + @v.z * vec.y + @w.z * vec.z,
    )
  end

  def self.from_w(n : Normal)
    w = n.to_vector
    a = w.x.abs > 0.9 ? Vector.y : Vector.x

    v = w.cross(a).normalize
    u = w.cross(v)

    ONB.new(u, v, w)
  end
end
