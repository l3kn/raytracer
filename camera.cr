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
  getter u : Vec3
  getter v : Vec3
  getter w : Vec3
  getter lower_left_corner : Vec3
  getter horizontal : Vec3
  getter vertical : Vec3
  getter lens_radius : Float64

  def initialize(look_from : Vec3,
                 look_at : Vec3,
                 up : Vec3,
                 vertical_fov : Int32,
                 aspect_ratio : Float64,
                 aperture : Float64,
                 focus_distance : Float64)
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
