struct Mat3x3
  getter v1, v2, v3
  RADIANTS = (Math::PI / 180)

  def initialize(@v1 : Vec3, @v2 : Vec3, @v3 : Vec3)
  end

  def *(other : Vec3)
    Vec3.new(
      v1.x * other.x + v2.x * other.y + v3.x * other.z,
      v1.y * other.x + v2.y * other.y + v3.y * other.z,
      v1.z * other.x + v2.z * other.y + v3.z * other.z
    )
  end

  def self.rotation_x(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    self.new(
      Vec3.new(1.0, 0.0, 0.0),
      Vec3.new(0.0, cos, sin),
      Vec3.new(0.0, -sin, cos)
    )
  end

  def self.rotation_y(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    self.new(
      Vec3.new(cos, 0.0, -sin),
      Vec3.new(0.0, 1.0, 0.0),
      Vec3.new(sin, 0.0, cos)
    )
  end

  def self.rotation_z(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    self.new(
      Vec3.new(cos, sin, 0.0),
      Vec3.new(-sin, cos, 0.0),
      Vec3.new(0.0, 0.0, 1.0)
    )
  end
end
