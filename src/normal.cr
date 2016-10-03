struct Normal
  getter x, y, z

  def initialize(@x : Float64, @y : Float64, @z : Float64)
    # TODO: add global epsilon constant
    {% if flag?(:release) %}
      if (self.dot(self) - 1.0).abs > 0.001
        raise "Error, length of normal is != 1"
      end
    {% end %}
  end

  def *(other : Float64)
    Vector.new(@x * other, @y * other, @z * other)
  end

  def dot(other)
    @x * other.x + @y * other.y + @z * other.z
  end

  def flip
    Normal.new(-@x, -@y, -@z)
  end

  # TODO: this is only used by onb.cr:14
  # in combination with pdf distributions around a normal
  def normalize
    self
  end

  def to_vector
    Vector.new(@x, @y, @z)
  end

  def xyz
    {@x, @y, @z}
  end
end
