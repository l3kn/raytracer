class DirectLightingRaytracer < BaseRaytracer
  def initialize(width, height, camera, samples, scene, filter = BoxFilter.new(0.5),
                 @sample_background = true, @strategy = :sample_one, @light_samples = 1)
    super(width, height, camera, samples, scene, filter)
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
