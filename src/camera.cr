require "./vector"
require "./transformation"

abstract class Camera
  abstract def generate_ray(x : Float64, y : Float64,
                            t_min : Float64, t_max : Float64) : Ray
end

class ProjectiveCamera < Camera
  getter raster_to_camera : Transformation

  def initialize(look_from : Point,
                 look_at : Point,
                 projection : Transformation,
                 dimensions : Tuple(Int32, Int32),
                 @lens_radius : Float64,
                 @focus_distance : Float64,
                 up = Vector.y)
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
    @camera_to_world.world_to_object(Ray.new(point_camera, Vector.z))
  end
end

class OrtographicCamera < ProjectiveCamera
  def initialize(look_from : Point,
                 look_at : Point,
                 dimensions : Tuple(Int32, Int32),
                 focus_distance = (look_from - look_at).length,
                 lens_radius = 0.0,
                 up = Vector.y)
    super(look_from, look_at, Transformation.orthographic(0.0, 1.0), dimensions, lens_radius, focus_distance, up)
  end

  def generate_ray(s, t, t_min, t_max)
    point_camera = @raster_to_camera.world_to_object(Point.new(s, t, 0.0))
    @camera_to_world.world_to_object(Ray.new(point_camera, Vector.z))
  end

  def corresponding(point : Point) : {Float64, Float64}
    l_0 = @camera_to_world.object_to_world(point)
    p = Point.new(l_0.x, l_0.y, 0.0)

    @raster_to_camera.object_to_world(p).xy
  end
end

class DefocusSampler
  @radius : Float64
  def initialize(@radius)
  end

  def sample
    random_in_unit_circle * @radius
  end
end

class PolygonSampler < DefocusSampler
  @radius : Float64
  @n : Int32
  @limit : Float64 # (distance from P_2 to P_3 in the explanation below)
  @prerotation : Float64
  def initialize(@radius, @n, @prerotation = 0.0)
    @limit = Math.sqrt(@radius ** 2 - (@radius * Math.sin(Math::PI / @n)) ** 2)
  end

  def sample
    point = Point.new(random, random, 0.0) * @radius

    until valid?(point)
      point = Point.new(random, random, 0.0) * @radius
    end

    point
  end

  # The length of side of a regular polygon with n sides
  # is a = 2*r*sin(pi / n)
  # 
  # If we construct a triangle
  # P_1 = one edge
  # P_2 = center of the polygon
  # P_3 = middle of a side adjacent to P_1
  #
  # The distance (P_1 to P_2) is given by r,
  # (P_1 to P_3) is given by a / 2
  # and the angle between (P_1 to P_3) and (P_2 to P_3) is 90deg
  #
  # So (P_2 to P_3) can be calculated by
  # \sqrt{ r^2 - r * sin(\pi / n)}
  # or, if r = 1
  # \sqrt{ 1 - sin(\pi / n)}
  def valid?(point)
      point = rotate(point, @prerotation)
    @n.times do |i|
      return false if point.x > @limit
      point = rotate(point, 360.0 / @n)
    end
    true
  end

  def rotate(point, degrees)
    x = point.x
    y = point.y

    angle = degrees * RADIANTS

    s = Math.sin(angle)
    c = Math.cos(angle)

    Point.new(
      c*x - s*y,
      s*x + c*y,
      0.0
    )
  end
end

class PerspectiveCamera < ProjectiveCamera
  @defocus_sampler : DefocusSampler
  def initialize(look_from : Point,
                 look_at : Point,
                 dimensions : Tuple(Int32, Int32),
                 lens_radius : Float64 = 0.0,
                 focus_distance : Float64 = 0.0,
                 vertical_fov : Float64 = 45.0,
                 up = Vector.y,
                 @defocus_sampler = DefocusSampler.new(lens_radius))
                 # @defocus_sampler = PolygonSampler.new(lens_radius, 7))
    super(look_from, look_at, Transformation.perspective(vertical_fov, EPSILON, 1000.0), dimensions, lens_radius, focus_distance, up)
  end

  def generate_ray(s, t, t_min, t_max)
    point = @raster_to_camera.world_to_object(Point.new(s, t, 0.0))
    ray = Ray.new(Point.new(0.0), Vector.new(point.x, point.y, 1.0).normalize, t_min, t_max)

    if @lens_radius > 0.0
      ft = @focus_distance / ray.direction.z
      focus_point = ray.point_at_parameter(ft)

      offset = @defocus_sampler.sample

      ray = Ray.new(offset, (focus_point - offset).normalize, t_min, t_max)
    end

    @camera_to_world.world_to_object(ray)
  end
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
