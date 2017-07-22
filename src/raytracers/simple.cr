class Raytracer
  class Simple < Base
    def cast_ray(ray)
      l = ::Color::BLACK
      path_throughput = ::Color::WHITE

      (0...@recursion_depth).each do |depth|
        hit = @scene.hit(ray)
        if hit.nil?
          l += path_throughput * @scene.get_background(ray)
          break
        end

        # Compute emitted and reflected light at intersection
        bsdf = hit.material.bsdf(hit)
        wo = -ray.direction

        l += path_throughput * bsdf.emitted(wo)

        sample = bsdf.sample_f(wo, BxDFType::All)
        break if sample.nil? || !sample.relevant?

        path_throughput *= sample.color * sample.dir.dot(hit.normal).abs / sample.pdf

        ray = Ray.new(hit.point, sample.dir)
      end

      l
    end
  end
end
