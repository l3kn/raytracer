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
