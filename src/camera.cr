require "./vector"

class Camera
  getter u : Vector, v : Vector, w : Vector
  getter lower_left_corner : Point
  getter horizontal : Vector
  getter vertical : Vector
  getter lens_radius : Float64

  def initialize(look_from : Point,
                 look_at : Point,
                 vertical_fov : Int32,
                 aspect_ratio : Float64,
                 up = Vector::Y,
                 aperture = 0.0)
    initialize(look_from, look_at, up, vertical_fov, aspect_ratio, aperture, (look_from - look_at).length)
  end

  def initialize(look_from : Point,
                 look_at : Point,
                 up : Vector,
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

    direction = @lower_left_corner - @origin - offset + @horizontal * s + @vertical * t
    # direction = @horizontal * s + @vertical * t - @origin - offset + @lower_left_corner

    Ray.new(@origin + offset, direction.normalize)
  end
end
