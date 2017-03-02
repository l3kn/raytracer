class SimpleRaytracer < BaseRaytracer
  def cast_ray(ray)
    l = Color::BLACK
    path_throughput = Color::WHITE

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

      sample = bsdf.sample_f(wo, BxDFType::ALL)
      break if sample.nil?

      f, wi, pdf, sampled_type = sample
      break if pdf == 0.0

      path_throughput *= f * wi.dot(hit.normal).abs / pdf

      ray = Ray.new(hit.point, wi)
    end

    l
  end
end

