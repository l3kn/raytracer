abstract class Camera
  abstract def generate_ray(
    x : Float64, y : Float64,
    t_min : Float64, t_max : Float64
  ) : Ray
  abstract def corresponding(p : Point) : {Int32, Int32}
end

class EnvironmentCamera < Camera
  @origin : Point
  @size_x : Int32
  @size_y : Int32

  def initialize(look_from : Point, look_at : Point, dimensions : Tuple(Int32, Int32), up = Vector.y)
    dir = (look_at - look_from).normalize
    left = up.normalize.cross(dir).normalize
    new_up = dir.cross(left)

    @origin = look_from
    @onb = ONB.new(left, new_up, dir)
    @size_x, @size_y = dimensions
  end

  def generate_ray(s, t, t_min, t_max)
    theta = Math::PI * t / @size_y
    phi = 2.0 * Math::PI * s / @size_x

    # NOTE: This direction is already normalized bc/ sin^2 + cos^2 = 1
    direction = Vector.new(
      Math.sin(theta) * Math.cos(phi),
      Math.cos(theta),
      Math.sin(theta) * Math.sin(phi)
    )

    Ray.new(@origin, @onb.local_to_world(direction), t_min, t_max)
  end

  def corresponding(point : Point)
    c = @onb.world_to_local(point).normalize

    theta = Math.acos(c.y)
    phi = Math.acos(c.x / Math.sin(theta))

    {
      (phi * INV_PI / 2.0 * @size_x).to_i,
      (theta * INV_PI * @size_y).to_i,
    }
  end
end

class PerspectiveCamera < Camera
  @lens_radius : Float64
  @size_x : Float64
  @size_y : Float64
  @onb : ONB
  @factor : Vector

  def initialize(
     look_from : Point,
     look_at : Point,
     vertical_fov : Float64,
     dimensions : Tuple(Int32, Int32),
     up = Vector.y,
     aperture = 0.0
  )
    initialize(look_from, look_at, up, vertical_fov, dimensions, aperture, (look_from - look_at).length)
  end

  def initialize(
    look_from : Point,
    look_at : Point,
    up : Vector,
    vertical_fov : Float64,
    dimensions : Tuple(Int32, Int32),
    aperture : Float64,
    focus_distance : Float64
  )
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

    # Extract some factors to make sure all bases of the ONB are normals
    @factor = Vector.new(
      half_width * focus_distance,
      half_height * focus_distance,
      fac_w = focus_distance
    )
    @lens_radius = aperture / 2
    @onb = ONB.new(u, v, -w)
  end

  def generate_ray(s, t, t_min, t_max)
    s = (s / @size_x * 2.0) - 1.0
    t = -((t / @size_y * 2.0) - 1.0)
    # TODO: Add this back in
    # rd = random_in_unit_circle * @lens_radius
    # offset = @u * rd.x + @v * rd.y

    direction = @onb.local_to_world(Vector.new(s, t, 1.0) * @factor)
    Ray.new(@origin, direction.normalize, t_min, t_max)
  end

  def corresponding(point : Point)
    dir = point - @origin
    c = @onb.world_to_local(dir.normalize)

    c /= @factor
    # Make sure c.z == 1.0
    c /= c.z

    {
      ((c.x + 1.0) / 2.0 * @size_x).to_i,
      ((-c.y + 1.0) / 2.0 * @size_y).to_i,
    }
  end
end
