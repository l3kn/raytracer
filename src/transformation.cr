require "./matrix4"

# TODO: Rename classes
# Transform => Transformation
# Transformation => MatrixTransformation?

abstract class Transform
  abstract def world_to_object(point : Point) : Point
  abstract def world_to_object(point : Normal) : Normal
  abstract def world_to_object(point : Vector) : Vector
  abstract def world_to_object(point : Ray) : Ray

  abstract def object_to_world(point : Point) : Point
  abstract def object_to_world(point : Normal) : Normal
  abstract def object_to_world(point : Vector) : Vector
  abstract def object_to_world(point : Ray) : Ray
  abstract def object_to_world(point : AABB) : AABB
end

class TransformationWrapper < FiniteHitable
  def initialize(@object : FiniteHitable, @transformation : Transform)
    @bounding_box = transformation.object_to_world(@object.bounding_box)
  end

  def hit(ray : Ray)
    new_ray = @transformation.world_to_object(ray)
    hit = @object.hit(new_ray)

    if hit
      HitRecord.new(
        hit.t,
        @transformation.object_to_world(hit.point),
        @transformation.object_to_world(hit.normal),
        hit.material,
        hit.object,
        hit.u, hit.v
      )
    else
      nil
    end
  end
end

class VS < Transform
  @inv_scale : Float64

  # TODO: Make this code less messy
  def initialize(@translation = Vector.new(0.0),
                 @scale = 1.0)

    @inv_scale = 1.0 / @scale
  end

  def world_to_object(point : Point) : Point
    (point - @translation) * @inv_scale
  end

  def object_to_world(point : Point) : Point
    point * @scale + @translation
  end

  def world_to_object(point : Vector) : Vector
    point * @inv_scale
  end

  def object_to_world(point : Vector) : Vector
    point * @scale
  end

  def world_to_object(n : Normal) : Normal
    n
  end

  def object_to_world(n : Normal) : Normal
    n
  end

  def world_to_object(ray : Ray)
    Ray.new(world_to_object(ray.origin), world_to_object(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(ray : Ray)
    Ray.new(object_to_world(ray.origin), object_to_world(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(box : AABB)
    AABB.new(
      object_to_world(box.min),
      object_to_world(box.max)
    )
  end
end

class VQS < Transform
  @inv_scale : Float64
  @rotation : Quaternion
  @inv_rotation : Quaternion

  # TODO: Make this code less messy
  # TODO: All quaternions are of unit length =>
  # conjugation could be simpler
  def initialize(@translation = Vector.new(0.0),
                 @scale = 1.0,
                 axis = Vector.x,
                 degrees = 0.0)

    @inv_scale = 1.0 / @scale
    rad = radiants(degrees)

    @rotation = Quaternion.new(
      Math.cos(rad / 2.0),
      axis * Math.sin(rad / 2.0)
    )
    @inv_rotation = @rotation.inverse
  end

  def world_to_object(point : Point) : Point
    a = (point - @translation)
    trans_ = Quaternion.new(1.0, a.x, a.y, a.z)
    rot_ = @inv_rotation * trans_ * @rotation
    rot = rot_.yzw.to_point
    rot * @inv_scale
  end

  def object_to_world(point : Point) : Point
    a = point * @scale
    b = Quaternion.new(1.0, a.x, a.y, a.z)
    c = @rotation * b * @inv_rotation

    c.yzw.to_point + @translation
  end

  def world_to_object(point : Vector) : Vector
    trans_ = Quaternion.new(0.0, point)
    rot_ = @inv_rotation * trans_ * @rotation
    rot = rot_.yzw
    rot * @inv_scale
  end

  def object_to_world(point : Vector) : Vector
    b = Quaternion.new(0.0, point)
    c = @rotation * b * @inv_rotation

    c.yzw + @translation
  end

  def world_to_object(n : Normal) : Normal
    trans_ = Quaternion.new(0.0, n.x, n.y, n.z)
    r = @inv_rotation * trans_ * @rotation
    r.yzw.to_normal
  end

  def object_to_world(n : Normal) : Normal
    b = Quaternion.new(0.0, n.x, n.y, n.z)
    r = @rotation * b * @inv_rotation
    r.yzw.to_normal
  end

  def world_to_object(ray : Ray)
    Ray.new(world_to_object(ray.origin), world_to_object(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(ray : Ray)
    Ray.new(object_to_world(ray.origin), object_to_world(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(box : AABB)
    # TODO: Currently, this doesn't work with rotations
    AABB.new(
      object_to_world(box.min),
      object_to_world(box.max)
    )
  end
end

class Transformation < Transform
  ID = self.new(
    Matrix4.new(
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0
    )
  )

  property matrix : Matrix4
  property inverse : Matrix4

  def initialize(@matrix)
    @inverse = @matrix.invert
  end

  def initialize(@matrix, @inverse)
  end

  def world_to_object(point_or_vector : (Point | Vector))
    @matrix * point_or_vector
  end

  def object_to_world(point_or_vector : (Point | Vector))
    @inverse * point_or_vector
  end

  def world_to_object(normal : Normal)
    # For normals the transformation
    # works the other way around
    # and the matrix is transposed,
    # but that fact is hidden in the `Matrix4.*(other : Normal)` functon
    @inverse * normal
  end

  def object_to_world(normal : Normal)
    @matrix * normal
  end

  def world_to_object(ray : Ray)
    Ray.new(world_to_object(ray.origin), world_to_object(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(ray : Ray)
    Ray.new(object_to_world(ray.origin), object_to_world(ray.direction), ray.t_min, ray.t_max)
  end

  def object_to_world(box : AABB)
    # An `AABB` box
    # can be defined by a center point `c`
    # and an offset vector `o` that is positive in all its components.
    #
    # This way `@min = c - o` and `@max = c + o`
    #
    # If we were to apply a transformation matrix `M` to the box,
    # we would need to recalculate all `@min` and `@max` like this:
    #
    # ```
    # new_box = AABB.new(
    #   min( M * (c +- o) ),
    #   max( M * (c +- o) )
    # )
    # ```
    #
    # where `(c +- o)` is short for
    # `Point.new(c_x +- o_x, c_y +- o_y, c_z +- o_z)`,
    # meaning all 2*2*2 = 8 different possible points
    #
    # This way we would need to do 16 (or 8, if we use a combined min-max function)
    # Mat-Point multiplications.
    #
    # `M * (c +- o)` is equivalent to
    # ```
    #   M[0...3, 0] * (c.x +- o.x)
    # + M[0...3, 1] * (c.y +- o.y)
    # + M[0...3, 2] * (c.z +- o.z)
    # + M[0...3, 3]
    # ```
    # where `M[0...3, n]` denotes the (first 3 rows of the) n-th column of the matrix
    # 
    # Using the equality from above
    # and the fact that min((a +- b) + (c +- d)) == min(a +- b) + min(c +- d),
    # we can turn `min( M * (c +- o) )` (and analogously `max(...)`) into
    #
    # ```
    #   min(M[0...3, 0] * (c.x +- o.x))
    # + min(M[0...3, 1] * (c.y +- o.y))
    # + min(M[0...3, 2] * (c.z +- o.z))
    # + M[0...3, 3]
    # ```
    # which uses only 12 (or 6) vector multiplications
    # and is (according to some quick benchmarks)
    # ~15x faster

    # In this code we assume,
    # that the last row of the inverse is (0, 0, 0, 1)^T
    unless @inverse.a30 == 0.0 && @inverse.a31 == 0.0 && @inverse.a32 == 0.0
      raise "Unexpected transformation matrix format: #{@inverse.inspect}"
    end
    
    center = box.centroid
    offset = box.max - center

    tmp = center.x - offset.x
    a_1 = Point.new(@inverse.a00 * tmp, @inverse.a10 * tmp, @inverse.a20 * tmp)

    tmp = center.x + offset.x
    a_2 = Point.new(@inverse.a00 * tmp, @inverse.a10 * tmp, @inverse.a20 * tmp)

    tmp = center.y - offset.y
    b_1 = Point.new(@inverse.a01 * tmp, @inverse.a11 * tmp, @inverse.a21 * tmp)

    tmp = center.y + offset.y
    b_2 = Point.new(@inverse.a01 * tmp, @inverse.a11 * tmp, @inverse.a21 * tmp)

    tmp = center.z - offset.z
    c_1 = Point.new(@inverse.a02 * tmp, @inverse.a12 * tmp, @inverse.a22 * tmp)

    tmp = center.z + offset.z
    c_2 = Point.new(@inverse.a02 * tmp, @inverse.a12 * tmp, @inverse.a22 * tmp)

    rest = Point.new(@inverse.a03, @inverse.a13, @inverse.a23)

    AABB.new(
      a_1.min(a_2) + b_1.min(b_2) + c_1.min(c_2) + rest,
      a_1.max(a_2) + b_1.max(b_2) + c_1.max(c_2) + rest
    )
  end

  def *(other : Transformation)
    Transformation.new(
      @matrix * other.matrix,
      other.inverse * @inverse
    )
  end

  def swaps_handedness?
    det = ((@matrix.a00 *
            (@matrix.a11 * @matrix.a22 -
             @matrix.a12 * @matrix.a21)) -
           (@matrix.a01 *
             (@matrix.a10 * @matrix.a22 -
              @matrix.a12 * @matrix.a20)) +
           (@matrix.a02 *
             (@matrix.a10 * @matrix.a21 -
              @matrix.a11 * @matrix.a20)))

    det < 0.0
  end

  def translate(x, y, z)
    self * translation(x, y, z)
  end

  def self.translation(x, y, z)
    Transformation.new(
      Matrix4.new(
        1.0, 0.0, 0.0, x,
        0.0, 1.0, 0.0, y,
        0.0, 0.0, 1.0, z,
        0.0, 0.0, 0.0, 1.0
      ),
      Matrix4.new(
        1.0, 0.0, 0.0, -offset.x,
        0.0, 1.0, 0.0, -offset.y,
        0.0, 0.0, 1.0, -offset.z,
        0.0, 0.0, 0.0, 1.0
      )
    )
  end

  def self.translation(offset)
    Transformation.new(
      Matrix4.new(
        1.0, 0.0, 0.0, offset.x,
        0.0, 1.0, 0.0, offset.y,
        0.0, 0.0, 1.0, offset.z,
        0.0, 0.0, 0.0, 1.0
      ),
      Matrix4.new(
        1.0, 0.0, 0.0, -offset.x,
        0.0, 1.0, 0.0, -offset.y,
        0.0, 0.0, 1.0, -offset.z,
        0.0, 0.0, 0.0, 1.0
      )
    )
  end

  def self.scaling(scale : Float64)
    self.scaling(scale, scale, scale)
  end

  def self.scaling(scale : Vector)
    self.scaling(scale.x, scale.y, scale.z)
  end

  def self.scaling(sx, sy, sz)
    Transformation.new(
      Matrix4.new(
        sx, 0.0, 0.0, 0.0,
        0.0, sy, 0.0, 0.0,
        0.0, 0.0, sz, 0.0,
        0.0, 0.0, 0.0, 1.0
      ),
      Matrix4.new(
        1.0 / sx, 0.0, 0.0, 0.0,
        0.0, 1.0 / sy, 0.0, 0.0,
        0.0, 0.0, 1.0 / sz, 0.0,
        0.0, 0.0, 0.0, 1.0
      )
    )
  end

  def self.rotation_x(angle)
    sin = Math.sin(angle * RADIANTS)
    cos = Math.cos(angle * RADIANTS)

    matrix = Matrix4.new(
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

    matrix = Matrix4.new(
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

    matrix = Matrix4.new(
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

    matrix = Matrix4.new(
      axis.x * axis.x + (1.0 - axis.x * axis.x) * cos,
      axis.x * axis.y * (1.0 - cos) - axis.z * sin,
      axis.x * axis.z * (1.0 - cos) + axis.y * sin,
      0.0,
      axis.x * axis.y * (1.0 - cos) + axis.z * sin,
      axis.y * axis.y + (1.0 - axis.y * axis.y) * cos,
      axis.y * axis.z * (1.0 - c) - axis.x * sin,
      0.0,
      axis.x * axis.z * (1.0 - cos) - axis.y * sin,
      axis.y * axis.z * (1.0 - cos) + axis.x * sin,
      axis.y * axis.z * (1.0 - axis.z * axis.z) * cos,
      0.0,
      0.0, 0.0, 0.0, 1.0
    )

    Transformation.new(matrix, matrix.transpose)
  end

  def self.look_at(look_from, look_at, up)
    matrix = Matrix4.new
    # dir = (look_from - look_at).normalize
    dir = (look_at - look_from).normalize
    left = up.normalize.cross(dir).normalize
    new_up = dir.cross(left)

    matrix = Matrix4.new(
      left.x, new_up.x, dir.x, look_from.x,
      left.y, new_up.y, dir.y, look_from.y,
      left.z, new_up.z, dir.z, look_from.z,
      0.0, 0.0, 0.0, 1.0
    )

    Transformation.new(matrix, matrix.invert)
  end

  def self.orthographic(z_near : Float64, z_far : Float64)
    self.scaling(Vector.new(1.0, 1.0, 1.0 / (z_far - z_near))) *
      self.translation(Vector.new(0.0, 0.0, -z_near))
  end

  def self.perspective(fov : Float64, n : Float64, f : Float64)
    result = Matrix4.new(
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, f/(f-n), -(f*n)/(f-n),
      0.0, 0.0, 1.0, 0.0
    )

    invTanAng = 1.0 / Math.tan(fov * RADIANTS / 2.0)
    self.scaling(Vector.new(invTanAng, invTanAng, 1.0)) * Transformation.new(result)
  end
end
