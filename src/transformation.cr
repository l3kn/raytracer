require "./mat4x4"

class TransformationWrapper < FiniteHitable
  def initialize(@object : FiniteHitable, @world_to_object : Transformation, @object_to_world : Transformation)
    @bounding_box = @object_to_world.apply(@object.bounding_box)
  end

  def hit(ray : Ray, t_min : Float, t_max : Float)
    new_ray = @world_to_object.apply(ray)
    hit = @object.hit(new_ray, t_min, t_max)

    if hit
      HitRecord.new(
        hit.t,
        @object_to_world.apply(hit.point),
        @object_to_world.apply(hit.normal),
        hit.material,
        hit.u, hit.v
      )
    else
      nil
    end
  end
end

class Transformation
  RADIANTS = (Math::PI / 180)

  property matrix : Mat4x4
  property inverse : Mat4x4

  def initialize(@matrix)
    @inverse = @matrix.inverse
  end

  def initialize(@matrix, @inverse)
  end

  def apply(point : Point)
    # Homogenous coordinates: (x y z 1)
    x, y, z = point.xyz

    xp = @matrix[0, 0] * x + @matrix[0, 1] * y + @matrix[0, 2] * z + @matrix[0, 3]
    yp = @matrix[1, 0] * x + @matrix[1, 1] * y + @matrix[1, 2] * z + @matrix[1, 3]
    zp = @matrix[2, 0] * x + @matrix[2, 1] * y + @matrix[2, 2] * z + @matrix[2, 3]
    wp = @matrix[3, 0] * x + @matrix[3, 1] * y + @matrix[3, 2] * z + @matrix[3, 3]

    wp == 1.0 ? Point.new(xp, yp, zp) : Point.new(xp / wp, yp / wp, zp / wp)
  end

  def apply(vector : Vector)
    # Homogenous coordinates: (x y z 0)
    x, y, z = vector.xyz

    xp = @matrix[0, 0] * x + @matrix[0, 1] * y + @matrix[0, 2] * z
    yp = @matrix[1, 0] * x + @matrix[1, 1] * y + @matrix[1, 2] * z
    zp = @matrix[2, 0] * x + @matrix[2, 1] * y + @matrix[2, 2] * z

    Vector.new(xp, yp, zp)
  end

  def apply(normal : Normal)
    # Homogenous coordinates: (x y z 0) but using the transposed inverse matrix
    x, y, z = normal.xyz

    xp = @inverse[0, 0] * x + @inverse[1, 0] * y + @inverse[2, 0] * z
    yp = @inverse[0, 1] * x + @inverse[1, 1] * y + @inverse[2, 1] * z
    zp = @inverse[0, 2] * x + @inverse[1, 2] * y + @inverse[2, 2] * z

    Normal.new(xp, yp, zp)
  end

  def apply(ray : Ray)
    Ray.new(apply(ray.origin), apply(ray.direction))
  end

  def apply(box : AABB)
    AABB.from_points([
      apply(Point.new(box.min.x, box.min.y, box.min.z)),
      apply(Point.new(box.min.x, box.min.y, box.max.z)),
      apply(Point.new(box.min.x, box.max.y, box.min.z)),
      apply(Point.new(box.min.x, box.max.y, box.max.z)),
      apply(Point.new(box.max.x, box.min.y, box.min.z)),
      apply(Point.new(box.max.x, box.min.y, box.max.z)),
      apply(Point.new(box.max.x, box.max.y, box.min.z)),
      apply(Point.new(box.max.x, box.max.y, box.max.z))
    ])
  end

  def *(other : Transformation)
    Transformation.new(
      @matrix * other.matrix,
      other.inverse * @inverse
    )
  end

  def swaps_handedness?
    det = ((@matrix[0, 0] *
            (@matrix[1, 1] * @matrix[2, 2] -
             @matrix[1, 2] * @matrix[2, 1])) -
           (@matrix[0, 1] *
             (@matrix[1, 0] * @matrix[2, 2] -
              @matrix[1, 2] * @matrix[2, 0])) +
           (@matrix[0, 2] *
             (@matrix[1, 0] * @matrix[2, 1] -
              @matrix[1, 1] * @matrix[2, 0])))

    det < 0.0
  end

  def self.translation(offset)
    Transformation.new(
      Mat4x4.new(
        1.0, 0.0, 0.0, offset.x,
        0.0, 1.0, 0.0, offset.y,
        0.0, 0.0, 1.0, offset.z,
        0.0, 0.0, 0.0, 1.0
      ),
      Mat4x4.new(
        1.0, 0.0, 0.0, -offset.x,
        0.0, 1.0, 0.0, -offset.y,
        0.0, 0.0, 1.0, -offset.z,
        0.0, 0.0, 0.0, 1.0
      )
    )
  end

  def self.scaling(scale)
    Transformation.new(
      Mat4x4.new(
        scale.x, 0.0, 0.0, 0.0,
        0.0, scale.y, 0.0, 0.0,
        0.0, 0.0, scale.z, 0.0,
        0.0, 0.0, 0.0, 1.0
      ),
      Mat4x4.new(
        1.0 / scale.x, 0.0, 0.0, 0.0,
        0.0, 1.0 / scale.y, 0.0, 0.0,
        0.0, 0.0, 1.0 / scale.z, 0.0,
        0.0, 0.0, 0.0, 1.0
      )
    )
  end

  def self.rotation_x(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    matrix = Mat4x4.new(
      1.0, 0.0,  0.0, 0.0,
      0.0, cos, -sin, 0.0,
      0.0, sin,  cos, 0.0,
      0.0, 0.0, 0.0, 1.0
    )

    Transformation.new(matrix, matrix.transpose)
  end

  def self.rotation_y(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    matrix = Mat4x4.new(
       cos, 0.0, sin, 0.0,
       0.0, 1.0, 0.0, 0.0,
      -sin, 0.0, cos, 0.0,
       0.0, 0.0, 0.0, 1.0
    )

    Transformation.new(matrix, matrix.transpose)
  end

  def self.rotation_z(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    matrix = Mat4x4.new(
      cos, -sin, 0.0, 0.0,
      sin,  cos, 0.0, 0.0,
      0.0,  0.0, 1.0, 0.0,
      0.0,  0.0, 0.0, 1.0
    )

    Transformation.new(matrix, matrix.transpose)
  end

  def self.rotation(angle, axis)
    axis = axis.normalize
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    matrix = Matrix4x4.new

    matrix[0, 0] = axis.x * axis.x + (1.0 - axis.x * axis.x) * cos
    matrix[0, 1] = axis.x * axis.y * (1.0 - cos) - axis.z * sin
    matrix[0, 2] = axis.x * axis.z * (1.0 - cos) + axis.y * sin
    matrix[0, 3] = 0.0

    matrix[1, 0] = axis.x * axis.y * (1.0 - cos) + axis.z * sin
    matrix[1, 1] = axis.y * axis.y + (1.0 - axis.y * axis.y) * cos
    matrix[1, 2] = axis.y * axis.z * (1.0 - c) - axis.x * sin
    matrix[1, 3] = 0.0

    matrix[2, 0] = axis.x * axis.z * (1.0 - cos) - axis.y * sin
    matrix[2, 1] = axis.y * axis.z * (1.0 - cos) + axis.x * sin
    matrix[2, 2] = axis.y * axis.z * (1.0 - axis.z * axis.z) * cos
    matrix[2, 3] = 0.0

    matrix[3, 0] = 0.0
    matrix[3, 1] = 0.0
    matrix[3, 2] = 0.0
    matrix[3, 3] = 1.0

    Transformation.new(matrix, matrix.transpose)
  end

  def self.look_at(look_from, look_at, up)
    matrix = Matrix4x4.new
    dir = (look_at - look_from).normalize
    left = up.normalize.cross(dir)
    newUp = dir.cross(left)

    matrix = Matrix4x4.new

    matrix[0, 0] = left.x
    matrix[1, 0] = left.y
    matrix[2, 0] = left.z
    matrix[3, 0] = 0.0
    matrix[0, 1] = newUp.x
    matrix[1, 1] = newUp.y
    matrix[2, 1] = newUp.z
    matrix[3, 1] = 0.0
    matrix[0, 2] = dir.x
    matrix[1, 2] = dir.y
    matrix[2, 2] = dir.z
    matrix[3, 2] = 0.0
    matrix[0, 3] = pos.x
    matrix[1, 3] = pos.y
    matrix[2, 3] = pos.z
    matrix[3, 3] = 1.0
  end
end
