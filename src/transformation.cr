abstract class Transformation
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
  def initialize(@object : FiniteHitable, @transformation : Transformation)
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

class VS < Transformation
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

class VQS < Transformation
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

# TODO: Implement this piece of code for the new transformations
# # An `AABB` box
# # can be defined by a center point `c`
# # and an offset vector `o` that is positive in all its components.
# #
# # This way `@min = c - o` and `@max = c + o`
# #
# # If we were to apply a transformation matrix `M` to the box,
# # we would need to recalculate all `@min` and `@max` like this:
# #
# # ```
# # new_box = AABB.new(
# #   min( M * (c +- o) ),
# #   max( M * (c +- o) )
# # )
# # ```
# #
# # where `(c +- o)` is short for
# # `Point.new(c_x +- o_x, c_y +- o_y, c_z +- o_z)`,
# # meaning all 2*2*2 = 8 different possible points
# #
# # This way we would need to do 16 (or 8, if we use a combined min-max function)
# # Mat-Point multiplications.
# #
# # `M * (c +- o)` is equivalent to
# # ```
# #   M[0...3, 0] * (c.x +- o.x)
# # + M[0...3, 1] * (c.y +- o.y)
# # + M[0...3, 2] * (c.z +- o.z)
# # + M[0...3, 3]
# # ```
# # where `M[0...3, n]` denotes the (first 3 rows of the) n-th column of the matrix
# # 
# # Using the equality from above
# # and the fact that min((a +- b) + (c +- d)) == min(a +- b) + min(c +- d),
# # we can turn `min( M * (c +- o) )` (and analogously `max(...)`) into
# #
# # ```
# #   min(M[0...3, 0] * (c.x +- o.x))
# # + min(M[0...3, 1] * (c.y +- o.y))
# # + min(M[0...3, 2] * (c.z +- o.z))
# # + M[0...3, 3]
# # ```
# # which uses only 12 (or 6) vector multiplications
# # and is (according to some quick benchmarks)
# # ~15x faster

# # In this code we assume,
# # that the last row of the inverse is (0, 0, 0, 1)^T
# unless @inverse.a30 == 0.0 && @inverse.a31 == 0.0 && @inverse.a32 == 0.0
#   raise "Unexpected transformation matrix format: #{@inverse.inspect}"
# end

# center = box.centroid
# offset = box.max - center

# tmp = center.x - offset.x
# a_1 = Point.new(@inverse.a00 * tmp, @inverse.a10 * tmp, @inverse.a20 * tmp)

# tmp = center.x + offset.x
# a_2 = Point.new(@inverse.a00 * tmp, @inverse.a10 * tmp, @inverse.a20 * tmp)

# tmp = center.y - offset.y
# b_1 = Point.new(@inverse.a01 * tmp, @inverse.a11 * tmp, @inverse.a21 * tmp)

# tmp = center.y + offset.y
# b_2 = Point.new(@inverse.a01 * tmp, @inverse.a11 * tmp, @inverse.a21 * tmp)

# tmp = center.z - offset.z
# c_1 = Point.new(@inverse.a02 * tmp, @inverse.a12 * tmp, @inverse.a22 * tmp)

# tmp = center.z + offset.z
# c_2 = Point.new(@inverse.a02 * tmp, @inverse.a12 * tmp, @inverse.a22 * tmp)

# rest = Point.new(@inverse.a03, @inverse.a13, @inverse.a23)

# AABB.new(
#   a_1.min(a_2) + b_1.min(b_2) + c_1.min(c_2) + rest,
#   a_1.max(a_2) + b_1.max(b_2) + c_1.max(c_2) + rest
# )
# end
