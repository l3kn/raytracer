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
require "./bsdf"
require "./integrator"
require "./materials/bxdf/*"
require "./materials/*"
require "./texture"
require "./background"
require "./backgrounds/*"
require "./pdf"
require "./fresnel"
require "./light"
require "./scene"

class BaseRaytracer
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
    @t_min = 0.0001
    @t_max = Float64::MAX
    @gamma_correction = 1.0/2.2
    @recursion_depth = 10
  end

  def render(filename)
    canvas = StumpyPNG::Canvas.new(@width, @height)
    samples_sqrt = Math.sqrt(samples).ceil

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
      end

      print "\rTraced line #{y} / #{@height}"
    end

    StumpyPNG.write(canvas, filename)
  end

  def cast_ray(ray, recursion_depth = @recursion_depth)
    hit = @scene.hit(ray)
    hit ? color(ray, hit, recursion_depth) : @scene.background.get(ray)
  end

  def color(ray, hit, recursion_depth)
    scatter = hit.material.scatter(ray, hit)
    if scatter
      scatter.albedo
    else
      Color::BLACK
    end
  end
end

class IntegratorRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene)
    super(width, height, camera, samples, scene)
    @integrator = Integrator.new(@scene)
  end

  def color(ray, hit, recursion_depth)
    @integrator.color(ray, hit, recursion_depth)
  end
end

#class Raytracer < BaseRaytracer
#  property focus_hitables : Hitable
#
#  def initialize(width, height, hitables, camera, samples, @focus_hitables, background = nil)
#    super(width, height, hitables, camera, samples, background)
#  end
#
#  def color(ray, hit, recursion_depth)
#    scatter = hit.material.scatter(ray, hit)
#    emitted = hit.material.emitted(ray, hit)
#    if scatter && recursion_depth > 0
#      pdf_or_ray = scatter.pdf_or_ray
#
#      if pdf_or_ray.is_a? Ray
#        scatter.albedo * cast_ray(pdf_or_ray, recursion_depth - 1)
#      else
#        p1 = HitablePDF.new(@focus_hitables, hit.point)
#        p = MixturePDF.new(p1, pdf_or_ray)
#        scattered = Ray.new(hit.point, p.generate, @t_min, @t_max)
#        pdf_val = p.value(scattered.direction)
#
#        pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
#        emitted + scatter.albedo * cast_ray(scattered, recursion_depth - 1) * pdf
#      end
#    else
#      emitted
#    end
#  end
#end

class SimpleRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    scatter = hit.material.scatter(ray, hit)
    if scatter && recursion_depth > 0
      pdf_or_ray = scatter.pdf_or_ray

      if pdf_or_ray.is_a? Ray
        scatter.albedo * cast_ray(pdf_or_ray, recursion_depth - 1)
      else
        scattered = Ray.new(hit.point, pdf_or_ray.generate, @t_min, @t_max)
        pdf_val = pdf_or_ray.value(scattered.direction)

        pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
        scatter.albedo * cast_ray(scattered, recursion_depth - 1) * pdf
      end
    else
      Color::BLACK
    end
  end
end
