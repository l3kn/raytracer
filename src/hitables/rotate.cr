require "../hitable"
require "../aabb"
require "../mat3x3"

class ApplyMatrix < Hitable
  getter object : Hitable
  getter bounding_box : AABB

  getter matrix : Mat3x3
  getter inverse : Mat3x3

  def initialize(@object, @matrix, @inverse)
    min = Vec3.new(-Float64::MAX)
    max = Vec3.new(Float64::MAX)
    bbox = @object.bounding_box

    (0...2).each do |i|
      (0...2).each do |j|
        (0...2).each do |k|
          ijk = Vec3.new(i.to_f, j.to_f, k.to_f)
          xyz = bbox.max * ijk + bbox.min * (Vec3::ONE - ijk)

          tester = @matrix * xyz
          max = max.max(tester)
          min = min.max(tester)
        end
      end
    end

    @bounding_box = AABB.new(min, max)
  end

  def hit(ray, t_min, t_max)
    rotated_origin = @inverse * ray.origin
    rotated_direction = @inverse * ray.direction
    rotated_ray = Ray.new(rotated_origin, rotated_direction)

    hit = @object.hit(rotated_ray, t_min, t_max)
    if hit
      HitRecord.new(
        hit.t,
        @matrix * hit.point,
        @matrix * hit.normal,
        hit.material,
        hit.u, hit.v
      )
    else
      nil
    end
  end

  def pdf_value(origin, direction)
    rotated_origin = @inverse * origin
    rotated_direction = @inverse * direction
    @object.pdf_value(rotated_origin, rotated_direction)
  end

  def random(origin)
    @matrix * @object.random(@inverse * origin)
  end
end

class RotateX < ApplyMatrix
  def initialize(object, angle)
    super(object, Mat3x3.rotation_x(angle), Mat3x3.rotation_x(-angle))
  end
end

class RotateY < ApplyMatrix
  def initialize(object, angle)
    super(object, Mat3x3.rotation_y(angle), Mat3x3.rotation_y(-angle))
  end
end

class RotateZ < ApplyMatrix
  def initialize(object, angle)
    super(object, Mat3x3.rotation_z(angle), Mat3x3.rotation_z(-angle))
  end
end
