class Mat4x4
  # TODO: use some faster datatype
  # TODO: currently the last row will always be (0, 0, 0, 1)^T
  #       and we even depend on it in some places
  #       (`Transformation.apply(box : AABB)`)
  #       If there is no case where we would need to change it,
  #       we could remove some checks and save space
  #       by using a 3x3 matrix for rotations
  #       and a Vector for the translation
  property values : Array(Array(Float64))

  def initialize(@values)
  end

  def initialize
    @values = [
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0]
    ]
  end

  def initialize(t00, t01, t02, t03,
                 t10, t11, t12, t13,
                 t20, t21, t22, t23,
                 t30, t31, t32, t33)
    @values = [
      [t00, t01, t02, t03],
      [t10, t11, t12, t13],
      [t20, t21, t22, t23],
      [t30, t31, t32, t33]
    ]
  end

  def transpose
    Mat4x4.new(
      @values[0][0], @values[1][0], @values[2][0], @values[3][0],
      @values[0][1], @values[1][1], @values[2][1], @values[3][1],
      @values[0][2], @values[1][2], @values[2][2], @values[3][2],
      @values[0][3], @values[1][3], @values[2][3], @values[3][3],
    )
  end

  def [](i, j)
    @values[i][j]
  end

  def []=(i, j, value : Float64)
    @values[i][j] = value
  end

  def *(other : Mat4x4)
    result = Mat4x4.new

    (0...4).each do |i|
      (0...4).each do |j|
        result[i, j] = self[i, 0] * other[0, j] +
                       self[i, 1] * other[1, j] +
                       self[i, 2] * other[2, j] +
                       self[i, 3] * other[3, j]
      end
    end

    result
  end

  def *(point : Point)
    # Homogenous coordinates: (x y z 1)
    x, y, z = point.xyz

    xp = self[0, 0] * x + self[0, 1] * y + self[0, 2] * z + self[0, 3]
    yp = self[1, 0] * x + self[1, 1] * y + self[1, 2] * z + self[1, 3]
    zp = self[2, 0] * x + self[2, 1] * y + self[2, 2] * z + self[2, 3]
    wp = self[3, 0] * x + self[3, 1] * y + self[3, 2] * z + self[3, 3]

    if wp == 1.0
      Point.new(xp, yp, zp)
    else
      inverse = 1.0 / wp
      Point.new(xp * inverse, yp * inverse, zp * inverse)
    end
  end

  def *(vector : Vector)
    # Homogenous coordinates: (x y z 0)
    x, y, z = vector.xyz

    xp = self[0, 0] * x + self[0, 1] * y + self[0, 2] * z
    yp = self[1, 0] * x + self[1, 1] * y + self[1, 2] * z
    zp = self[2, 0] * x + self[2, 1] * y + self[2, 2] * z

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
    x, y, z = vector.xyz

    xp = self[0, 0] * x + self[1, 0] * y + self[2, 0] * z
    yp = self[0, 1] * x + self[1, 1] * y + self[2, 1] * z
    zp = self[0, 2] * x + self[1, 2] * y + self[2, 2] * z

    Normal.new(xp, yp, zp)
  end

  def swap_rows(i, j)
    buf = @values[i]
    @values[i] = @values[j]
    @values[j] = buf
  end

  def clone
    result = Mat4x4.new
    (0...4).each do |i|
      (0...4).each do |j|
        result[i, j] = self[i, j]
      end
    end

    result
  end

  def invert
    indxc = [0, 0, 0, 0]
    indxr = [0, 0, 0, 0]
    ipiv = [0, 0, 0, 0]

    inverse = clone

    (0...4).each do |i|
      irow = 0
      icol = 0
      big = 0.0

      # Chose pivot
      (0...4).each do |j|
        if ipiv[j] != 1
          (0...4).each do |k|
            if ipiv[k] == 0
              if inverse[j, k].abs >= big
                big = inverse[j, k].abs
                irow = j
                icol = k
              end
            elsif ipiv[k] > 1
              raise "Singular Matrix"
            end
          end
        end
      end

      ipiv[icol] += 1

      inverse.swap_rows(irow, icol) if irow != icol

      indxr[i] = irow
      indxc[i] = icol

      raise "Singular Matrix" if inverse[icol, icol] == 0.0

      # set A[icol, icol] to one by scaling row `icol` appropriately
      pivinv = 1.0 / inverse[icol, icol]
      (0...4).each do |j|
        inverse[icol, j] = inverse[icol, j] * pivinv
      end

      # subtract this row from others to zero out their columns
      (0...4).each do |j|
        if j != icol
          save = inverse[j, icol]
          inverse[j, icol] = 0.0

          (0...4).each do |k|
            inverse[j, k] = inverse[j, k] - inverse[icol, k] * save
          end
        end
      end
    end

    # swap columns to reflect permutation
    (0...4).reverse_each do |j|
      if indxr[j] != indxc[j]
        (0...4).each do |k|
          tmp = inverse[k, indxr[j]]
          inverse[k, indxr[j]] = inverse[k, indxc[j]]
          inverse[k, indxc[j]] = tmp
        end
      end
    end

    inverse
  end
end
