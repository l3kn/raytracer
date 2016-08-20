class RotateY < Hitable
  getter angle : Float64
  getter object : Hitable
  getter bounding_box : AABB

  getter sin_theta : Float64
  getter cos_theta : Float64

  def initialize(@object, @angle)
    radiants = (Math::PI / 180) * @angle

    @sin_theta = Math.sin(radiants)
    @cos_theta = Math.cos(radiants)

    min_x = Float64::MIN
    min_y = Float64::MIN
    min_z = Float64::MIN

    max_x = Float64::MAX
    max_y = Float64::MAX
    max_z = Float64::MAX

    bbox = @object.bounding_box

    (0...2).each do |i|
      (0...2).each do |j|
        (0...2).each do |k|
          x = i*bbox.max.x + (1-i)*bbox.min.x
          y = j*bbox.max.y + (1-j)*bbox.min.y
          z = k*bbox.max.z + (1-k)*bbox.min.z

          tester = Vec3.new(
            @cos_theta*x + @sin_theta*z,
            y,
            -@sin_theta*x + @cos_theta*z
          )

          max_x = tester.x if tester.x > max_x
          max_y = tester.y if tester.y > max_y
          max_z = tester.z if tester.z > max_z

          min_x = tester.x if tester.x < min_x
          min_y = tester.y if tester.y < min_y
          min_z = tester.z if tester.z < min_z
        end
      end
    end

    @bounding_box = AABB.new(
      Vec3.new(min_x, min_y, min_z),
      Vec3.new(max_x, max_y, max_z)
    )
  end
  
  def hit(ray, t_min, t_max)
    rotated_origin = Vec3.new(
      @cos_theta*ray.origin.x - @sin_theta*ray.origin.z,
      ray.origin.y,
      @sin_theta*ray.origin.x + @cos_theta*ray.origin.z,
    )

    rotated_direction = Vec3.new(
      @cos_theta*ray.direction.x - @sin_theta*ray.direction.z,
      ray.direction.y,
      @sin_theta*ray.direction.x + @cos_theta*ray.direction.z,
    )

    rotated_ray = Ray.new(rotated_origin, rotated_direction)

    hit = @object.hit(rotated_ray, t_min, t_max)
    if hit
      rotated_point = Vec3.new(
        @cos_theta*hit.point.x + @sin_theta*hit.point.z,
        hit.point.y,
        -@sin_theta*hit.point.x + @cos_theta*hit.point.z,
      )

      rotated_normal = Vec3.new(
        @cos_theta*hit.normal.x + @sin_theta*hit.normal.z,
        hit.normal.y,
        -@sin_theta*hit.normal.x + @cos_theta*hit.normal.z,
      )

      Intersection.new(
        hit.t,
        rotated_point,
        rotated_normal,
        hit.material,
        hit.u,
        hit.v
      )
    else
      nil
    end
  end
end
