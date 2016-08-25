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
require "./pdf"
require "./pdfs/*"

class Raytracer
  property width : Int32
  property height : Int32
  property world : Hitable
  property light_shape : Hitable
  property camera : Camera
  property samples : Int32
  property background : Background
  property debug : Bool

  def initialize(@width, @height, @world, @camera, @samples, @light_shape, background = nil, @debug = false)
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

            # Cap each sample at 1.0,
            # so that one bright sample
            # does not mess up the whole pixel
            col += color(ray, world)#.min(1.0)
          end
        end

        col /= (samples_sqrt * samples_sqrt)
        col = col.min(1.0)
        col **= 0.45 # Gamma Correction

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
    hit = world.hit(ray, 0.0001, Float64::MAX)
    if hit
      return Vec3.new(1.0) + hit.normal * 0.5 if @debug

      scatter = hit.material.scatter(ray, hit)
      emitted = hit.material.emitted(ray, hit)
      if scatter && recursion_level < RECURSION_LIMIT
        if scatter.is_specular
          spc = scatter.specular_ray
          if spc.nil?
            Vec3.new(0.0)
          else
            scatter.albedo * color(spc, world, recursion_level + 1)
          end
        else
          p1 = HitablePDF.new(@light_shape, hit.point)
          p = MixturePDF.new(p1, scatter.pdf)
          scattered = Ray.new(hit.point, p.generate)
          pdf_val = p.value(scattered.direction)

          pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
          emitted + scatter.albedo * color(scattered, world, recursion_level+1) * pdf
        end
      else
        emitted
      end
    else
      @background.get(ray)
    end
  end
end
