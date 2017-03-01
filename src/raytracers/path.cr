class PathRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene, filter = BoxFilter.new(0.5),
                 @sample_background = true)
    super(width, height, camera, samples, scene, filter)
  end

  # TODO: convert this to be recursive or merge w/ cast_ray
  def color(ray, hit, recursion_depth)
    # Declare common path integration variables
    l = Color::BLACK
    path_throughput = Color::WHITE
    specular_bounce = false

    (0...@recursion_depth).each do |depth|
      bsdf = hit.material.bsdf(hit)
      wo = -ray.direction

      l += path_throughput * bsdf.emitted(wo) if depth == 0 || specular_bounce
      l += path_throughput * uniform_sample_one_light(hit, bsdf, wo, @sample_background)

      # sample bsdf to get new path dir
      sample = bsdf.sample_f(wo, BxDFType::ALL)
      break if sample.nil?

      f, wi, pdf, sampled_type = sample
      break if pdf == 0.0

      specular_bounce = (sampled_type & BxDFType::SPECULAR) != 0
      path_throughput *= f * wi.dot(hit.normal).abs / pdf

      # possibliy terminate the path
      if depth > 3
        continue_probability = min(0.5, path_throughput.max)
        break if rand > continue_probability

        # scale the throughput accordingly
        path_throughput /= continue_probability
      end

      new_ray = Ray.new(hit.point, wi)

      hit = @scene.fast_hit(ray)
      if hit.nil?
        l += path_throughput * @scene.background.get(new_ray) if specular_bounce
        break
      end
    end

    l
  end
end
