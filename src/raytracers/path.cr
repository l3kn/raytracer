class Raytracer
  class Path < Base
    def initialize(dimensions, camera, samples, scene, filter = BoxFilter.new(0.5),
                   @sample_background = true)
      super(dimensions, camera, samples, scene, filter)
    end

    def cast_ray(ray)
      # Declare common path integration variables
      l = ::Color::BLACK
      path_throughput = ::Color::WHITE
      specular_bounce = false

      (0...@recursion_depth).each do |depth|
        hit = @scene.hit(ray)
        if hit.nil?
          l += path_throughput * @scene.get_background(ray) if specular_bounce
          break
        end

        bsdf = hit.material.bsdf(hit)
        wo = -ray.direction

        l += path_throughput * bsdf.emitted(wo) if depth == 0 || specular_bounce
        l += path_throughput * uniform_sample_one_light(hit, bsdf, wo)
        l += path_throughput * estimate_background(hit, bsdf, wo)

        # sample bsdf to get new path dir
        sample = bsdf.sample_f(wo, BxDFType::All)
        break if sample.nil? || !sample.relevant?

        specular_bounce = sample.type.specular?
        path_throughput *= sample.color * sample.dir.dot(hit.normal).abs / sample.pdf

        # possibliy terminate the path
        if depth > 3
          continue_probability = min(0.5, path_throughput.max_component)
          break if rand > continue_probability

          # scale the throughput accordingly
          path_throughput /= continue_probability
        end

        ray = Ray.new(hit.point, sample.dir)
      end

      l
    end
  end
end
