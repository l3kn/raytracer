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

