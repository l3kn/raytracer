require "stumpy_png"
require "./vec3"
require "./ray"
require "./hitable"
require "./hitables/*"
require "./camera"
require "./helper"
require "./material"
require "./materials/*"
require "./texture"
require "./aabb"
require "./background"
require "./backgrounds/*"

class GIRaytracer
  property width : Int32
  property height : Int32
  property world : Hitable
  property camera : Camera
  property samples : Int32
  property background : Background

  def initialize(@width, @height, @world, @camera, @samples, background = nil)
    if background.nil?
      @background = ConstantBackground.new(Vec3.new(1.0))
    else
      @background = background
    end
  end

  def render(filename)
    canvas = StumpyPNG::Canvas.new(@width, @height)
    samples_sqrt = Math.sqrt(samples).ceil

    (0...@height).each do |y|
      (0...@width).each do |x|
        col = Vec3.new(0.0)

        (0...samples_sqrt).each do |i|
          (0...samples_sqrt).each do |j|
            off_x = (i + rand) / samples_sqrt
            off_y = (j + rand) / samples_sqrt

            u = (x + off_x).to_f / @width
            v = (y + off_y).to_f / @height

            ray = camera.get_ray(u, v)

            col += color(ray, world)
          end
        end

        col /= (samples_sqrt * samples_sqrt)

        rgba = StumpyPNG::RGBA.new(
          (UInt16::MAX * col.x).to_u16,
          (UInt16::MAX * col.y).to_u16,
          (UInt16::MAX * col.z).to_u16,
          UInt16::MAX
        )

        canvas.set_pixel(x, (@height - 1) - y, rgba)
      end

      print "\rTraced line #{y} / #{@height}"
    end

    StumpyPNG.write(canvas, filename)
  end

  RECURSION_LIMIT = 10

  def color(ray, world, recursion_level = 0)
    if recursion_level >= RECURSION_LIMIT
      return Vec3.new(0.0)
    end

    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      s_color = Vec3.new(0.8)
      d_color = applyLightning(hit.point, hit.normal)
    else
      @background.get(ray)
    end
  end

  def applyLightning(point, normal)
    dcol = Vec3.new(0.0)

    # Sample sun
    # TODO

    # Sample sky
    light_point = cosineDirection(normal) * 1000.0
    light_ray = Ray.new(point, (light_point - point).normalize)

    dcol += Vec3.new(0.5, 0.7, 1.0) * worldShadow(light_ray)
  end

  def worldShadow(ray)
    world.hit(ray, 0.0001, 9999.9) ? 0.0 : 1.0
  end

  def cosineDirection(normal)
    random_on_hemisphere(normal)
  end
end
