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
require "./background"
require "./backgrounds/*"
require "./pdf"

class NormalRaytracer
  property width : Int32
  property height : Int32
  property samples : Int32
  property camera : Camera
  property hitables : Hitable
  property background : Background
  property t_min : Float64
  property t_max : Float64
  property gamma_correction : Float64

  def initialize(@width, @height, @hitables, @camera, @samples, background = nil)
    if background.nil?
      @background = ConstantBackground.new(Vec3::ONE)
    else
      @background = background
    end

    @t_min = 0.0001
    @t_max = Float64::MAX
    @gamma_correction = 1.0/2.2
  end

  def render(filename)
    canvas = StumpyPNG::Canvas.new(@width, @height)
    samples_sqrt = Math.sqrt(samples).ceil

    (0...@height).each do |y|
      (0...@width).each do |x|
        col = Vec3::ZERO

        (0...samples_sqrt).each do |i|
          (0...samples_sqrt).each do |j|
            off_x = (i + rand) / samples_sqrt
            off_y = (j + rand) / samples_sqrt

            u = (x + off_x).to_f / @width
            v = (y + off_y).to_f / @height

            ray = @camera.get_ray(u, v)
            col += de_nan(color(ray, hitables))
          end
        end

        col /= (samples_sqrt * samples_sqrt)
        col = col.min(1.0)
        col **= @gamma_correction # Gamma Correction

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

  def color(ray, hitables)
    hit = hitables.hit(ray, @t_min, @t_max)
    if hit
      Vec3::ONE * 0.5 + hit.normal
    else
      @background.get(ray)
    end
  end
end

class Raytracer < NormalRaytracer
  property focus_hitables : Hitable
  property recursion_depth : Int32

  def initialize(width, height, hitables, camera, samples, @focus_hitables, background = nil)
    super(width, height, hitables, camera, samples, background)
    @recursion_depth = 10
  end

  def color(ray, hitables, recursion_depth = @recursion_depth)
    hit = hitables.hit(ray, @t_min, @t_max)
    if hit
      scatter = hit.material.scatter(ray, hit)
      emitted = hit.material.emitted(ray, hit)
      if scatter && recursion_depth > 0
        pdf_or_ray = scatter.pdf_or_ray

        if pdf_or_ray.is_a? Ray
          scatter.albedo * color(pdf_or_ray, hitables, recursion_depth - 1)
        else
          p1 = HitablePDF.new(@focus_hitables, hit.point)
          p = MixturePDF.new(p1, pdf_or_ray)
          scattered = Ray.new(hit.point, p.generate)
          pdf_val = p.value(scattered.direction)

          pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
          emitted + scatter.albedo * color(scattered, hitables, recursion_depth - 1) * pdf
        end
      else
        emitted
      end
    else
      @background.get(ray)
    end
  end
end

class SimpleRaytracer < NormalRaytracer
  property recursion_depth : Int32

  def initialize(width, height, hitables, camera, samples, background = nil)
    super(width, height, hitables, camera, samples)
    @recursion_depth = 10
  end

  def color(ray, hitables, recursion_depth = @recursion_depth)
    hit = hitables.hit(ray, @t_min, @t_max)
    if hit
      scatter = hit.material.scatter(ray, hit)
      if scatter && recursion_depth > 0
        pdf_or_ray = scatter.pdf_or_ray

        if pdf_or_ray.is_a? Ray
          scatter.albedo * color(pdf_or_ray, hitables, recursion_depth - 1)
        else
          scattered = Ray.new(hit.point, pdf_or_ray.generate)
          pdf_val = pdf_or_ray.value(scattered.direction)

          pdf = hit.material.scattering_pdf(ray, hit, scattered) / pdf_val
          scatter.albedo * color(scattered, hitables, recursion_depth - 1) * pdf
        end
      else
        Vec3::ZERO
      end
    else
      @background.get(ray)
    end
  end
end
