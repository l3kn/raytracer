abstract class Raytracer
  property width : Int32, height : Int32, samples : Int32
  property camera : Camera
  property scene : Scene
  property gamma_correction : Float64

  def initialize(dimensions, @camera, @samples, @scene)
    @width, @height = dimensions
    @gamma_correction = 1.0 / 2.2
  end

  abstract def render_to_canvas(filename : String, adaptive = false)

  def render(filename, adaptive = false)
    StumpyPNG.write(render_to_canvas(filename, adaptive), filename)
  end

  def uniform_sample_one_light(hit, bsdf, wo)
    return Color::BLACK if @scene.lights.size == 0

    light_pdf = 1.0 / (@scene.lights.size)
    estimate_direct(@scene.lights.sample, hit, bsdf, wo) / light_pdf
  end

  def uniform_sample_all_lights(hit, bsdf, wo)
    color = Color::BLACK
    return color if @scene.lights.size == 0

    light_pdf = 1.0 / @scene.lights.size
    @scene.lights.each do |light|
      color += estimate_direct(light, hit, bsdf, wo) / light_pdf
    end
  end

  def estimate_background(hit, bsdf, wo, flags = ~BxDFType::Specular)
    background = @scene.background
    return Color::BLACK if background.nil?

    sample = bsdf.sample_f(wo, flags)
    return Color::BLACK if sample.nil?

    f, wi, bsdf_pdf, sampled_type = sample
    weight = 1.0
    unless sampled_type.specular?
      weight = power_heuristic(1, INV_PI, 1, bsdf_pdf)
    end

    ray = Ray.new(hit.point, wi)
    return Color::BLACK if @scene.fast_hit(ray)

    li = background.get(ray)
    f * li * wi.dot(hit.normal).abs * weight / bsdf_pdf
  end

  def estimate_direct(light, hit, bsdf, wo, flags = ~BxDFType::Specular)
    ld = Color::BLACK

    # Sample light w/ multiple importance sampling
    wi, li, visibility, light_pdf = light.sample_l(hit.normal, scene, hit.point)

    unless light_pdf == 0.0 || li.black?
      f = bsdf.f(wo, wi, flags)
      if visibility.unoccluded?(@scene) && !f.black?
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
        return ld if f.black? || bsdf_pdf == 0.0

        unless sampled_type.specular?
          light_pdf = light.pdf(hit.point, wi)
          return ld if light_pdf == 0.0
          weight = power_heuristic(1, bsdf_pdf, 1, light_pdf)
        end

        # Add weight contribution from BSDF sampling
        ray = Ray.new(hit.point, wi)
        light_hit = @scene.hit(ray)

        if light_hit && light_hit.object.area_light == light
          li = light_hit.material.bsdf(light_hit).emitted(-wi)
          ld += f * li * wi.dot(hit.normal).abs * weight / bsdf_pdf unless li.black?
        end
      end
    end

    ld
  end
end

abstract class BaseRaytracer < Raytracer
  property recursion_depth : Int32
  property filter : Filter

  def initialize(dimensions, camera, samples, scene, @filter = BoxFilter.new(0.5))
    super(dimensions, camera, samples, scene)
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

        ray = @camera.generate_ray(x + off_x, y + off_y, EPSILON, Float64::MAX)
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

        vis.set(:variance, x, y, sample.variance.length)
        rgba = sample.mean.to_rgba(@gamma_correction)
        canvas[x, y] = rgba

        print_pixel(rgba, mode: :grayscale) if (x % pr_x) == 0 && (y % pr_y) == 0
      end
      print "\n" if (y % pr_y) == 0
      # print "\rTraced line #{y} / #{@height}"
    end

    time = Time.now - start

    puts "\nTime: #{(time.total_milliseconds / 1000).round(3)}s"
    puts "Total rays: #{Ray.count}"
    puts "Rays / sec: #{((Ray.count.to_f / time.total_milliseconds) * 1000).round(3)}"

    vis.write(:variance, "variance_" + filename)
    canvas
  end

  abstract def cast_ray(ray)
end
