require "stumpy_png"
require "./vec3"
require "./ray"
require "./hitable"
require "./hitable/*"
require "./camera"
require "./helper"
require "./material"
require "./material/*"
require "./texture"
require "./aabb"

class Raytracer
  property width : Int32
  property height : Int32
  property world : Hitable
  property camera : Camera
  property samples : Int32

  def initialize(@width, @height, @world, @camera, @samples)
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

      puts "Traced line #{y} / #{@height}"
    end

    StumpyPNG.write(canvas, filename)
  end

  RECURSION_LIMIT = 10

  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      scatter = hit.material.scatter(ray, hit)
      emitted = hit.material.emitted(hit)
      if scatter && recursion_level < RECURSION_LIMIT
        emitted + scatter.albedo * color(scatter.ray, world, recursion_level + 1)
      else
        emitted
      end
    else
      Vec3.new(0.0)
    end
  end
end
