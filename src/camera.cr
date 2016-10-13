require "./vector"
require "./transformation"

abstract class Camera
  abstract def generate_ray(x : Float64, y : Float64,
                            t_min : Float64, t_max : Float64) : Ray
end

class ProjectiveCamera < Camera
  @raster_to_camera : Transformation

  def initialize(look_from : Point,
                 look_at : Point,
                 projection : Transformation,
                 dimensions : Tuple(Int32, Int32),
                 @lens_radius : Float64,
                 @focus_distance : Float64,
                 up = Vector::Y)
    initialize(Transformation.look_at(look_from, look_at, up),
               projection, dimensions,
               lens_radius, focus_distance)
  end

  # `camera_to_world` is from camera-space to world-space
  def initialize(@camera_to_world : Transformation,
                 projection : Transformation,
                 dimensions : Tuple(Int32, Int32),
                 @lens_radius : Float64,
                 @focus_distance : Float64)
    aspect_ratio = dimensions[0].to_f / dimensions[1]

    if aspect_ratio > 1.0
      min_x = -aspect_ratio
      max_x = aspect_ratio
      min_y = -1.0
      max_y = 1.0
    else
      min_x = -1.0
      max_x = 1.0
      min_y = -1.0 / aspect_ratio
      max_y = 1.0 / aspect_ratio
    end

    # Compute projective camera camera_to_worlds
    camera_to_screen = projection

    # The y-coordinate is inverted,
    # because it moves up in screen space
    # but down in the image
    # TODO: for some reason the x-axis seems to be flipped, to
    screen_to_raster = Transformation.scaling(dimensions[0].to_f, dimensions[1].to_f, 1.0) *
      Transformation.scaling(1.0 / (min_x - max_x), 1.0 / (min_y - max_y), 1.0) *
      Transformation.translation(Vector.new(-max_x, -max_y, 0.0))
    raster_to_screen = Transformation.new(screen_to_raster.inverse, screen_to_raster.matrix)

    @raster_to_camera = Transformation.new(camera_to_screen.inverse, camera_to_screen.matrix) * raster_to_screen
  end

  def generate_ray(s, t, t_min, t_max)
    point_camera = @raster_to_camera.world_to_object(Point.new(s, t, 0.0))
    @camera_to_world.world_to_object(Ray.new(point_camera, Vector.new(0.0, 0.0, 1.0)))
  end
end

class OrtographicCamera < ProjectiveCamera
  def initialize(look_from : Point,
                 look_at : Point,
                 dimensions : Tuple(Int32, Int32),
                 lens_radius : Float64,
                 focus_distance : Float64,
                 up = Vector::Y)
    super(look_from, look_at, Transformation.orthographic(0.0, 1.0), dimensions, lens_radius, focus_distance, up)
  end

  def generate_ray(s, t, t_min, t_max)
    point_camera = @raster_to_camera.world_to_object(Point.new(s, t, 0.0))
    @camera_to_world.world_to_object(Ray.new(point_camera, Vector.new(0.0, 0.0, 1.0)))
  end
end

class PerspectiveCamera < ProjectiveCamera
  def initialize(look_from : Point,
                 look_at : Point,
                 dimensions : Tuple(Int32, Int32),
                 lens_radius : Float64 = 0.0,
                 focus_distance : Float64 = 0.0,
                 vertical_fov : Float64 = 45.0,
                 up = Vector::Y)
    super(look_from, look_at, Transformation.perspective(vertical_fov, 0.001, 1000.0), dimensions, lens_radius, focus_distance, up)
  end

  def generate_ray(s, t, t_min, t_max)
    point = @raster_to_camera.world_to_object(Point.new(s, t, 0.0))
    ray = Ray.new(Point.new(0.0), Vector.new(point.x, point.y, 1.0).normalize, t_min, t_max)

    if @lens_radius > 0.0
      ft = @focus_distance / ray.direction.z
      focus_point = ray.point_at_parameter(ft)

      offset = random_in_unit_circle * @lens_radius

      ray = Ray.new(offset, (focus_point - offset).normalize, t_min, t_max)
    end

    @camera_to_world.world_to_object(ray)
  end
end

class EnvironmentCamera < Camera
  @camera_to_world : Transformation
  @size_x : Int32
  @size_y : Int32
  def initialize(look_from : Point, look_at : Point, dimensions : Tuple(Int32, Int32), up = Vector::Y)
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


class OldCamera < Camera
  getter u : Vector, v : Vector, w : Vector
  getter lower_left_corner : Point
  getter horizontal : Vector
  getter vertical : Vector
  getter lens_radius : Float64

  @size_x : Float64
  @size_y : Float64

  def initialize(look_from : Point,
                 look_at : Point,
                 vertical_fov : Float64,
                 dimensions : Tuple(Int32, Int32),
                 up = Vector::Y,
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

    @w = (look_from - look_at).normalize
    @u = up.cross(@w).normalize
    @v = @w.cross(@u)

    @origin = look_from
    @lower_left_corner = @origin - @u * half_width * focus_distance - @v * half_height * focus_distance - @w * focus_distance
    @horizontal = @u * 2 * half_width * focus_distance
    @vertical = @v * 2 * half_height * focus_distance
    @lens_radius = aperture / 2
  end

  def generate_ray(s, t, t_min, t_max)
    s = s / @size_x
    t = t / @size_y
    rd = random_in_unit_circle * @lens_radius
    offset = @u * rd.x + @v * rd.y

    direction = @lower_left_corner - @origin - offset + @horizontal * s + @vertical * t
    # direction = @horizontal * s + @vertical * t - @origin - offset + @lower_left_corner

    Ray.new(@origin + offset, direction.normalize, t_min, t_max)
  end
end
