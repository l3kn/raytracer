require "./vector"
require "./transformation"

abstract class Camera
  abstract def generate_ray(x : Float64, y : Float64,
                            t_min : Float64, t_max : Float64) : Ray
end

class EnvironmentCamera < Camera
  @camera_to_world : Transformation
  @size_x : Int32
  @size_y : Int32
  def initialize(look_from : Point, look_at : Point, dimensions : Tuple(Int32, Int32), up = Vector.y)
    @camera_to_world = Transformation.look_at(look_from, look_at, up)
    @size_x, @size_y = dimensions
  end

  def generate_ray(s, t, t_min, t_max)
    theta = Math::PI * t / @size_y
    phi = 2.0 * Math::PI * s / @size_x

    direction = Vector.new(Math.sin(theta) * Math.cos(phi),
                           Math.cos(theta),
                           Math.sin(theta) * Math.sin(phi))
    ray = Ray.new(Point.new(0.0), direction, t_min, t_max)

    @camera_to_world.world_to_object(ray)
  end
end

class PerspectiveCamera < Camera
  @lens_radius : Float64
  @size_x : Float64
  @size_y : Float64
  @onb : ONB

  def initialize(look_from : Point,
                 look_at : Point,
                 vertical_fov : Float64,
                 dimensions : Tuple(Int32, Int32),
                 up = Vector.y,
                 aperture = 0.0)
    initialize(look_from, look_at, up, vertical_fov, dimensions, aperture, (look_from - look_at).length)
  end

  def initialize(look_from : Point,
                 look_at : Point,
                 up : Vector,
                 vertical_fov : Float64,
                 dimensions : Tuple(Int32, Int32),
                 aperture : Float64,
                 focus_distance : Float64)

    aspect_ratio = dimensions[0].to_f / dimensions[1]
    @size_x = dimensions[0].to_f
    @size_y = dimensions[1].to_f

    theta = vertical_fov * Math::PI / 180
    half_height = Math.tan(theta / 2.0)
    half_width = aspect_ratio * half_height

    w = (look_from - look_at).normalize
    u = up.cross(w).normalize
    v = w.cross(u)

    @origin = look_from

    horizontal = u * half_width * focus_distance
    vertical = v * half_height * focus_distance

    @lens_radius = aperture / 2
    @onb = ONB.new(horizontal, vertical, -w * focus_distance)
  end

  def generate_ray(s, t, t_min, t_max)
    s = (s / @size_x * 2.0) - 1.0
    t = -((t / @size_y * 2.0) - 1.0)
    # rd = random_in_unit_circle * @lens_radius
    # offset = @u * rd.x + @v * rd.y

    direction = @onb.local_to_world(Vector.new(s, t, 1.0))
    Ray.new(@origin, direction.normalize, t_min, t_max)
  end

  def corresponding(point : Point)
    c = @onb.world_to_local(point)
    # Make sure c.z == 1.0
    c /= c.z

    { 
      (c.x + 1.0 / 2.0 * @size_x).to_i,
      (-c.y + 1.0 / 2.0 * @size_y).to_i
    }
  end
end
