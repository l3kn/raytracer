EPSILON = 0.0001

require "../../linalg/src/linalg"
require "../../stumpy_utils/src/stumpy_utils"

require "stumpy_png"
require "./vector"
require "./normal"
require "./color"
require "./point"
require "./quaternion"
require "./ray"
require "./hitable"
# TODO: This needs to be required first, bc/ Cuboid < FiniteHitableList
#       maybe create a separate folder for aggregate hitables
require "./hitables/hitable_list"
require "./hitables/*"
require "./camera"
require "./helper"
require "./material"
require "./bxdf"
require "./bxdfs/*"
require "./bsdf"
require "./texture"
require "./background"
require "./backgrounds/*"
require "./light"
require "./onb"
require "./scene"
require "./sample"
require "./wireframe"

abstract class Raytracer
  property width : Int32
  property height : Int32
  property camera : Camera
  property samples : Int32
  property scene : Scene

  def initialize(@width, @height, @camera, @samples, @scene)
  end

  abstract def render(filename : String)

  def specular(ray, hit, bsdf, recursion_depth, type)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    sample = bsdf.sample_f(wo, BxDFType::SPECULAR | type)
    return Color::BLACK if sample.nil?

    color, wi, pdf, sampled_type = sample
    return Color::BLACK if wi.dot(normal).abs == 0.0

    new_ray = Ray.new(point, wi)
    li = cast_ray(new_ray, recursion_depth - 1)
    li * color * wi.dot(normal).abs / pdf
  end

  # TODO: remove point & normal params
  def uniform_sample_one_light(hit, wo, background = true)
    if background
      index = rand(0..@scene.lights.size)
      if index == 0
        estimate_background(hit, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
      else
        estimate_direct(@scene.lights[index - 1], hit, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
      end
    else
      estimate_direct(@scene.lights.sample, hit, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
    end
  end

  def uniform_sample_all_lights(hit, wo, background = true)
    color = Color::BLACK

    @scene.lights.each do |light|
      color += estimate_direct(light, hit, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
    end

    if background
      color += estimate_background(hit, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
      color / (@scene.lights.size + 1.0)
    else
      color / @scene.lights.size.to_f
    end
  end

  def estimate_background(hit, wo, flags)
    ld = Color::BLACK
    sample = hit.material.bsdf(hit).sample_f(wo, flags)

    if sample
      f, wi, bsdf_pdf, sampled_type = sample
      weight = 1.0
      unless sampled_type & BxDFType::SPECULAR
        light_pdf = 1.0 / Math::PI
        return ld if light_pdf == 0.0
        weight = power_heuristic(1, light_pdf, 1, bsdf_pdf)
      end

      ray = Ray.new(hit.point, wi)
      unless @scene.fast_hit(ray)
        li = @scene.background.get(ray)
        ld += f * li * wi.dot(hit.normal).abs * weight / bsdf_pdf
      end
    end
    ld
  end

  def estimate_direct(light, hit, wo, flags)
    ld = Color::BLACK

    # Sample light w/ multiple importance sampling
    wi, li, visibility, light_pdf = light.sample_l(hit.normal, scene, hit.point)
    bsdf = hit.material.bsdf(hit)

    unless light_pdf == 0.0 || li.black?
      f = bsdf.f(wo, wi, flags)
      if visibility.unoccluded?(@scene)# && f > EPSILON
        if light.delta_light?
          ld += f * li * (wi.dot(hit.normal).abs / light_pdf)
        else
          bsdf_pdf = bsdf.pdf(wo, wi, flags)
          weight = power_heuristic(1, light_pdf, 1, bsdf_pdf)
          ld += f * li * (wi.dot(hit.normal).abs * weight / light_pdf)
        end
      end
    end

    # Sample BSDF w/ multiple importance sampling
    unless light.delta_light?
      sample = bsdf.sample_f(wo, flags)

      if sample
        f, wi, bsdf_pdf, sampled_type = sample
        weight = 1.0
        unless sampled_type & BxDFType::SPECULAR
          light_pdf = light.pdf(hit.point, wi)
          return ld if light_pdf == 0.0
          weight = power_heuristic(1, bsdf_pdf, 1, light_pdf)
        end

        # Add weight contribution from BSDF sampling
        ray = Ray.new(hit.point, wi)
        hit = @scene.hit(ray)

        if hit && hit.object.area_light == light
          li = hit.material.bsdf(hit).emitted(-wi)
          ld += f * li * wi.dot(hit.normal).abs * weight / bsdf_pdf unless li.black?
        end
      end
    end

    ld
  end
end

class BaseRaytracer < Raytracer
  property t_min : Float64
  property t_max : Float64
  property gamma_correction : Float64
  property recursion_depth : Int32
  property filter : Filter

  def initialize(width, height, camera, samples, scene, @filter = BoxFilter.new(0.5))
    super(width, height, camera, samples, scene)
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
      chars = "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,\"^`'. ".reverse
      gray = 0.3 * r + 0.6 * g + 0.1 * b
      print chars[(gray / 256 * chars.size).to_i]
    end
  end

  def sample_pixel(sample, x, y, samples)
    # Box filter, size 1.0
    size = 4.0
    samples_sqrt = Math.sqrt(samples).ceil
    (0...samples_sqrt).each do |i|
      (0...samples_sqrt).each do |j|
        off_x = (((i + rand) / samples_sqrt) - 0.5) * 2 * @filter.width_x
        off_y = (((j + rand) / samples_sqrt) - 0.5) * 2 * @filter.width_y

        ray = @camera.generate_ray(x + off_x, y + off_y, @t_min, @t_max)
        # sample.add(cast_ray(ray).de_nan, triangle_filter(off_x, off_y))
        sample.add(cast_ray(ray).de_nan, @filter.evaluate(off_x, off_y))
      end
    end
  end

  def render_to_canvas(filename, adaptive = false)
    canvas = StumpyPNG::Canvas.new(@width, @height)
    vis = Visualisation.new(@width, @height)
    vis.add_layer(:variance)

    pr_x = @width / 80
    pr_y = (pr_x / 0.4).to_i

    start = Time.now

    (0...@height).each do |y|
      (0...@width).each do |x|
        sample = Sample.new

        if adaptive
          sample_pixel(sample, x, y, samples / 2)
          var = sample.variance
          sample_pixel(sample, x, y, samples * 2) if var.squared_length >= 0.1
        else
          sample_pixel(sample, x, y, samples)
        end

        col = sample.mean
        vis.set(:variance, x, y, sample.variance.length)

        col = col.min(1.0)
        col **= @gamma_correction # Gamma Correction

        rgba = StumpyPNG::RGBA.new(
          (UInt16::MAX * col.r).to_u16,
          (UInt16::MAX * col.g).to_u16,
          (UInt16::MAX * col.b).to_u16,
          UInt16::MAX
        )

        canvas[x, y] = rgba

        print_pixel(rgba, mode: :grayscale) if (x % pr_x) == 0 && (y % pr_y) == 0
      end
      print "\n" if (y % pr_y) == 0
      # print "\rTraced line #{y} / #{@height}"
    end

    time = Time.now - start

    puts ""
    puts "Time: #{(time.total_milliseconds / 1000).round(3)}s"
    puts "Total rays: #{Ray.count}"
    puts "Rays / sec: #{((Ray.count.to_f / time.total_milliseconds) * 1000).round(3)}"

    vis.write(:variance, "variance_" + filename)

    canvas
  end

  def render(filename, adaptive = false)
    StumpyPNG.write(render_to_canvas(filename, adaptive), filename)
  end

  def cast_ray(ray, recursion_depth = @recursion_depth)
    hit = @scene.hit(ray)
    hit ? color(ray, hit, recursion_depth) : @scene.background.get(ray)
  end

  def color(ray : Ray, hit : HitRecord, recursion_depth : Int32) : Color
    Color::BLACK
  end
end

class SimpleRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    return Color::BLACK if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material.bsdf(hit)
    point = hit.point
    normal = hit.normal

    wo = -ray.direction

    # TODO: Only emit light to one side

    sample = bsdf.sample_f(wo, BxDFType::ALL)
    return bsdf.emitted(wo) if sample.nil?

    color, wi, pdf, sampled_type = sample
    return Color::BLACK if wi.dot(normal).abs == 0.0

    color += bsdf.emitted(wo)

    new_ray = Ray.new(point, wi)
    li = cast_ray(new_ray, recursion_depth - 1)

    color * li * wi.dot(normal).abs / pdf
  end
end

class NormalRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    Color.new(
      (1.0 + hit.normal.x) * 0.5,
      (1.0 + hit.normal.y) * 0.5,
      (1.0 + hit.normal.z) * 0.5,
    )
  end
end

class WhittedRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material.bsdf(hit)
    point = hit.point
    normal = hit.normal

    wo = -ray.direction

    color += bsdf.emitted(wo)

    # Sample each light
    @scene.lights.each do |light|
      wi, li, visibility, pdf = light.sample_l(normal, scene, point)
      if pdf == 0.0 || li.black?
        next
      else
        f = bsdf.f(wo, wi, BxDFType::ALL)
        if visibility.unoccluded?(@scene)# && f > EPSILON
          color += f * li * wi.dot(normal).abs / pdf
        end
      end
    end

    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::REFLECTION)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::TRANSMISSION)

    # Sample the background
    sample = bsdf.sample_f(wo, BxDFType::ALL & ~BxDFType::SPECULAR)
    if sample
      f, wi, bsdf_pdf, sampled_type = sample
      weight = 1.0
      unless sampled_type & BxDFType::SPECULAR
        light_pdf = 1.0 / Math::PI
        return color if light_pdf == 0.0
        weight = power_heuristic(1, light_pdf, 1, bsdf_pdf)
      end

      ray = Ray.new(point, wi)
      unless @scene.fast_hit(ray)
        li = @scene.background.get(ray)
        color += f * li * wi.dot(normal).abs * weight / bsdf_pdf
      end
    end

    color
  end
end

class DirectLightingRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene, filter = BoxFilter.new(0.5),
                 @sample_background = true, @strategy = :sample_one, @light_samples = 1)
    super(width, height, camera, samples, scene)
  end

  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material.bsdf(hit)
    point = hit.point
    normal = hit.normal
    wo = -ray.direction

    color += bsdf.emitted(wo)

    # Sample each light + the background
    case @strategy
    when :sample_all
      @light_samples.times do
        color += uniform_sample_all_lights(hit, wo, @sample_background) / @light_samples.to_f
      end
    when :sample_one
      @light_samples.times do
        color += uniform_sample_one_light(hit, wo, @sample_background) / @light_samples.to_f
      end
    else
      raise "Unknown strategy for direct lighting integrator: #{@strategy}"
    end

    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::REFLECTION)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::TRANSMISSION)
    color
  end
end

class PathRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene, filter = BoxFilter.new(0.5),
                 @sample_background = true)
    super(width, height, camera, samples, scene, filter)
  end

  def color(ray, hit, recursion_depth)
    # Declare common path integration variables

    l = Color::BLACK
    path_throughput = Color::WHITE
    specular_bounce = false

    bounces = 0
    loop do 
      bsdf = hit.material.bsdf(hit)
      p = hit.point
      n = hit.normal

      wo = -ray.direction

      # Possibly add emitted light
      l += path_throughput * bsdf.emitted(wo) if bounces == 0 || specular_bounce

      # sample illumination from lights
      l += path_throughput * uniform_sample_one_light(hit, wo, @sample_background)

      # sample bsdf to get new path dir
      sample = bsdf.sample_f(wo, BxDFType::ALL)
      break if sample.nil?

      f, wi, pdf, sampled_type = sample
      break if pdf == 0.0

      specular_bounce = (sampled_type & BxDFType::SPECULAR) != 0
      path_throughput *= f * wi.dot(n).abs / pdf

      ray = Ray.new(p, wi)

      # possibliy terminate the path
      # break if bounces == @max_bounces
      break if bounces == @recursion_depth
      if bounces > 3
        # use a "random" component of path_throughput
        # to terminate "dark" rays with a higher probability
        # TODO: use maximum of path_throughput here
        continue_probability = min(0.5, path_throughput.g)
        break if rand > continue_probability

        # scale the throughput accordingly
        path_throughput /= continue_probability
      end

      # find next vertex of path
      hit = @scene.hit(ray)
      if hit.nil?
        l += path_throughput * @scene.background.get(ray) if specular_bounce
        break
      end

      bounces += 1
    end

    l
  end
end
