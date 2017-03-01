class WhittedRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    bsdf = hit.material.bsdf(hit)
    wo = -ray.direction

    # emitted + incoming (lights & background) + reflections / transmissions
    color += bsdf.emitted(wo)
    color += uniform_sample_all_lights(hit, bsdf, wo, false)
    color += estimate_background(hit, bsdf, wo, BxDFType::ALL & ~BxDFType::SPECULAR)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::REFLECTION)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::TRANSMISSION)

    color
  end
end
