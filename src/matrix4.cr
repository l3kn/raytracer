require "linalg"

struct Matrix4 < LA::AMatrix4
  def *(point : Point)
    # Homogenous coordinates: (x y z 1)
    x, y, z = point.to_tuple

    xp = self.a00 * x + self.a01 * y + self.a02 * z + self.a03
    yp = self.a10 * x + self.a11 * y + self.a12 * z + self.a13
    zp = self.a20 * x + self.a21 * y + self.a22 * z + self.a23
    wp = self.a30 * x + self.a31 * y + self.a32 * z + self.a33

    if wp == 1.0
      Point.new(xp, yp, zp)
    else
      inverse = 1.0 / wp
      Point.new(xp * inverse, yp * inverse, zp * inverse)
    end
  end

  def *(vector : Vector)
    # Homogenous coordinates: (x y z 0)
    x, y, z = vector.to_tuple

    xp = self.a00 * x + self.a01 * y + self.a02 * z
    yp = self.a10 * x + self.a11 * y + self.a12 * z
    zp = self.a20 * x + self.a21 * y + self.a22 * z

    Vector.new(xp, yp, zp)
  end

  # TODO: This is a little bit hacky,
  # this code is used in `Transformation`
  # and would normaly multiply with the transposed inverse matrix.
  # Because there are (currently) no cases were we need to multiply
  # with untransposed matrices, we just transpose the matrix
  # right in this function
  def *(vector : Normal)
    # Homogenous coordinates: (x y z 0)

    xp = self.a00 * x + self.a10 * y + self.a20 * z
    yp = self.a01 * x + self.a11 * y + self.a21 * z
    zp = self.a02 * x + self.a12 * y + self.a22 * z

    Normal.new(xp, yp, zp)
  end
end
