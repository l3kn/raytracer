EPSILON = 0.0001

require "stumpy_png"
require "./vector"
require "./normal"
require "./color"
require "./point"
require "./ray"
require "./hitable"
require "./hitables/*"
require "./camera"
require "./helper"
require "./material"
require "./bxdf"
require "./materials/*"
require "./texture"
require "./background"
require "./backgrounds/*"
require "./pdf"
require "./light"
require "./scene"

require "../../stumpy_term/src/stumpy_term"

abstract class Raytracer
  property width : Int32
  property height : Int32
  property samples : Int32
  property camera : Camera
  property t_min : Float64
  property t_max : Float64
  property gamma_correction : Float64
  property recursion_depth : Int32
  property scene : Scene

  def initialize(@width, @height, @camera, @samples, @scene)
    @t_min = EPSILON
    @t_max = Float64::MAX
    @gamma_correction = 1.0/2.2
    @recursion_depth = 10
  end

  def print_pixel(color, mode = :truecolor)
    r, g, b = color.to_rgb8
    if mode == :truecolor
      print "\033[48;2;#{r};#{g};#{b}m \033[0m"
    else
      chars = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'. "
      gray = 0.3 * r + 0.6 * g + 0.1 * b
      print chars[(gray / 256 * chars.size).to_i]
    end
  end

  def render(filename)
    canvas = StumpyPNG::Canvas.new(@width, @height)
    samples_sqrt = Math.sqrt(samples).ceil

    pr_x = @width / 140
    pr_y = (pr_x / 0.4).to_i

    start = Time.now

    (0...@height).each do |y|
      (0...@width).each do |x|
        col = Color::BLACK

        (0...samples_sqrt).each do |i|
          (0...samples_sqrt).each do |j|
            off_x = (i + rand) / samples_sqrt
            off_y = (j + rand) / samples_sqrt

            x_ = (x + off_x).to_f
            y_ = (y + off_y).to_f

            ray = @camera.generate_ray(x_, y_, @t_min, @t_max)
            col += cast_ray(ray).de_nan
          end
        end

        col /= (samples_sqrt * samples_sqrt)
        col = col.min(1.0)
        col **= @gamma_correction # Gamma Correction

        rgba = StumpyPNG::RGBA.new(
          (UInt16::MAX * col.r).to_u16,
          (UInt16::MAX * col.g).to_u16,
          (UInt16::MAX * col.b).to_u16,
          UInt16::MAX
        )

        canvas[x, y] = rgba

        if (x % pr_x) == 0 && (y % pr_y) == 0
          print_pixel(rgba, mode: :grayscale)
        end
      end
      if (y % pr_y) == 0
        print "\n"
      end

      # print "\rTraced line #{y} / #{@height}"
    end

    time = Time.now - start

    puts ""
    puts "Time: #{(time.total_milliseconds / 1000).round(3)}s"
    StumpyPNG.write(canvas, filename)
  end

  def cast_ray(ray, recursion_depth = @recursion_depth)
    hit = @scene.hit(ray)
    hit ? color(ray, hit, recursion_depth) : @scene.background.get(ray)
  end

  abstract def color(ray : Ray, hit : HitRecord, recursion_depth : Int32) : Color
end

class SimpleRaytracer < Raytracer
  def color(ray, hit, recursion_depth)
    return Color::BLACK if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material
    point = hit.point
    normal = hit.normal

    wo = -ray.direction

    sample = bsdf.sample_f(hit, wo, BxDFType::All)
    return Color::BLACK if sample.nil?

    color, wi, pdf = sample
    return Color::BLACK if wi.dot(normal).abs == 0.0

    new_ray = Ray.new(point, wi)
    new_hit = @scene.hit(new_ray)
    if new_hit
      li = color(new_ray, new_hit, recursion_depth - 1)
    else
      li = @scene.background.get(new_ray)
    end

    color * li * wi.dot(normal).abs / pdf
  end
end

class WhittedRaytracer < Raytracer
  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material
    point = hit.point
    normal = hit.normal

    wo = -ray.direction

    # TODO: Implement emissive materials
    # color += hit.emitted

    # Sample each light
    @scene.lights.each do |light|
      wi, li, visibility, pdf = light.sample_l(point)
      f = bsdf.f(hit, wo, wi, BxDFType::All)

        color += f * li * wi.dot(normal).abs / pdf
      if visibility.unoccluded?(@scene)
      end
    end

    # Background lighting
    onb = ONB.from_w(normal)
    wi = onb.local(random_cosine_direction)
    foo = Ray.new(point, wi)

    unless @scene.fast_hit(foo)
      f = bsdf.f(hit, wo, wi, BxDFType::All)
      # TODO: Bad try at calculating a pdf for the infinite background light
      color += @scene.background.get(foo) * f * Math::PI  # * wi.dot(normal).abs * (2.0 * Math::PI)
    end

    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::Reflection)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::Transmission)
    color
  end

  def specular(ray, hit, bsdf, recursion_depth, type)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    sample = bsdf.sample_f(hit, wo, BxDFType::Specular | type)
    return Color::BLACK if sample.nil?

    color, wi, pdf = sample
    return Color::BLACK if wi.dot(normal).abs == 0.0

    new_ray = Ray.new(point, wi)
    new_hit = @scene.hit(new_ray)
    if new_hit
      li = color(new_ray, new_hit, recursion_depth - 1)
    else
      li = @scene.background.get(new_ray)
    end
    li * color * wi.dot(normal).abs / pdf
  end
end

# class Raytracer < BaseRaytracer
#   property focus_hitables : Hitable

#   def initialize(width, height, hitables, camera, samples, @focus_hitables, background = nil)
#     super(width, height, hitables, camera, samples, background)
#   end

#   def color(ray, hit, recursion_depth)
#     scatter = hit.material.scatter(ray, hit)
#     emitted = hit.material.emitted(ray, hit)
#     if scatter && recursion_depth > 0
#       pdf_or_ray = scatter.pdf_or_ray

#       if pdf_or_ray.is_a? Ray
#         scatter.albedo * cast_ray(pdf_or_ray, recursion_depth - 1)
#       else
#         p1 = HitablePDF.new(@focus_hitables, hit.point)
#         p = MixturePDF.new(p1, pdf_or_ray)
#         scattered = Ray.new(hit.point, p.generate, @t_min, @t_max)
#         pdf_val = p.value(scattered.direction)

#         pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
#         emitted + scatter.albedo * cast_ray(scattered, recursion_depth - 1) * pdf
#       end
#     else
#       emitted
#     end
#   end
# end
