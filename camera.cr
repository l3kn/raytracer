class OldCamera
  def initialize(look_from, look_at, up, vertical_fov, aspect_ratio)
    theta = vertical_fov * Math::PI / 180
    half_height = Math.tan(theta/2)
    half_width = aspect_ratio * half_height

    @origin = look_from

    w = (look_from - look_at).normalize
    u = up.cross(w).normalize
    v = w.cross(u)

    @lower_left_corner = @origin - u*half_width - v*half_height - w
    @horizontal = u*half_width*2
    @vertical = v*half_height*2
  end

  def get_ray(s, t)
    direction = @lower_left_corner + @horizontal*s + @vertical*t - @origin
    Ray.new(@origin, direction)
  end
end

class Camera
  def initialize(look_from, look_at, up, vertical_fov, aspect_ratio, aperture, focus_distance)
    theta = vertical_fov * Math::PI / 180
    half_height = Math.tan(theta / 2.0)
    half_width = aspect_ratio * half_height

    @w = (look_from - look_at).normalize
    @u = up.cross(@w).normalize
    @v = @w.cross(@u)

    @origin = look_from
    @lower_left_corner = @origin - @u * half_width * focus_distance - @v * half_height * focus_distance - @w * focus_distance
    @horizontal = @u * 2 * half_width * focus_distance
    @vertical = @v * 2 * half_height * focus_distance
    @lens_radius = aperture / 2
  end

  def get_ray(s, t)
    rd = random_in_unit_circle * @lens_radius
    offset = @u * rd.x + @v * rd.y

    direction = @lower_left_corner + @horizontal * s + @vertical * t - @origin - offset

    Ray.new(@origin + offset, direction)
  end
end
