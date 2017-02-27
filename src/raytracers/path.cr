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
        continue_probability = min(0.5, path_throughput.max)
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
