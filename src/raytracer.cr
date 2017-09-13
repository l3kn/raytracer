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
    start = Time.now

    StumpyPNG.write(render_to_canvas(filename, adaptive), filename)

    time = Time.now - start
    puts "\nTime: #{(time.total_milliseconds / 1000).round(3)}s"
    puts "Total rays: #{Ray.count}"
    puts "Rays / sec: #{((Ray.count.to_f / time.total_milliseconds) * 1000).round(3)}"
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

  def estimate_background(hit, bsdf, wo, flags = ~BxDF::Type::Specular)
    background = @scene.background
    return Color::BLACK if background.nil?

    sample = bsdf.sample_f(wo, flags)
    return Color::BLACK if sample.nil? || !sample.relevant?

    weight = 1.0
    unless sample.type.specular?
      weight = power_heuristic(1, INV_PI, 1, sample.pdf)
    end

    ray = Ray.new(hit.point, sample.dir)
    return Color::BLACK if @scene.fast_hit(ray)

    li = background.get(ray)
    sample.color * li * sample.dir.dot(hit.normal).abs * weight / sample.pdf
  end

  def estimate_direct(light, hit, bsdf, wo, flags = ~BxDF::Type::Specular)
    ld = Color::BLACK

    # Sample light w/ multiple importance sampling
    sample = light.sample_l(hit.normal, scene, hit.point)
    if sample.relevant?
      f = bsdf.f(wo, sample.dir, flags)
      if sample.tester.unoccluded?(@scene) && !f.black?
        if light.delta_light?
          ld += f * sample.color * (sample.dir.dot(hit.normal).abs / sample.pdf)
        else
          bsdf_pdf = bsdf.pdf(wo, sample.dir, flags)
          weight = power_heuristic(1, sample.pdf, 1, bsdf_pdf)
          ld += f * sample.color * (sample.dir.dot(hit.normal).abs * weight / sample.pdf)
        end
      end
    end

    # Sample BSDF w/ multiple importance sampling
    unless light.delta_light?
      sample = bsdf.sample_f(wo, flags)

      if sample
        weight = 1.0
        return ld unless sample.relevant?

        unless sample.type.specular?
          light_pdf = light.pdf(hit.point, sample.dir)
          return ld if light_pdf == 0.0
          weight = power_heuristic(1, sample.pdf, 1, light_pdf)
        end

        # Add weight contribution from BSDF sampling
        ray = Ray.new(hit.point, sample.dir)
        light_hit = @scene.hit(ray)

        if light_hit && light_hit.object.area_light == light
          li = light_hit.material.bsdf(light_hit).emitted(-sample.dir)
          ld += sample.color * li * sample.dir.dot(hit.normal).abs * weight / sample.pdf unless li.black?
        end
      end
    end

    ld
  end

  abstract class Base < Raytracer
    property recursion_depth : Int32

    def initialize(dimensions, camera, samples, scene)
      super(dimensions, camera, samples, scene)
      @recursion_depth = 10
    end

    def sample_pixel(sample, x, y, samples_sqrt, inv_samples_sqrt)
      (0...samples_sqrt).each do |i|
        (0...samples_sqrt).each do |j|
          off_x = (((i + rand) * inv_samples_sqrt) - 0.5)
          off_y = (((j + rand) * inv_samples_sqrt) - 0.5)

          ray = @camera.generate_ray(x + off_x, y + off_y, EPSILON, Float64::MAX)
          sample.add(cast_ray(ray).de_nan)
        end
      end
    end

    def render_to_canvas(filename, adaptive = false)
      canvas = StumpyPNG::Canvas.new(@width, @height)

      samples_sqrt = Math.sqrt(samples).ceil
      inv_samples_sqrt = 1.0 / samples_sqrt

      sample = Sample.new
      (0...@height).each do |y|
        (0...@width).each do |x|
          sample.reset
          sample_pixel(sample, x, y, samples_sqrt, inv_samples_sqrt)
          canvas[x, y] = sample.mean.to_rgba(@gamma_correction)
        end
        print "\rProgress: #{y} / #{@height}"
      end
      puts "\nDONE!"

      canvas
    end

    abstract def cast_ray(ray)
  end
end
