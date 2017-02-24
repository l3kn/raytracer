class WhittedRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    bsdf = hit.material.bsdf(hit)
    point = hit.point
    normal = hit.normal

    wo = -ray.direction

    color += bsdf.emitted(wo)

    # Sample each light
    @scene.lights.each do |light|
      wi, li, visibility, pdf = light.sample_l(normal, scene, point)
      if pdf == 0.0 || li.black?
        next
      else
        f = bsdf.f(wo, wi, BxDFType::ALL)
        if visibility.unoccluded?(@scene)# && f > EPSILON
          color += f * li * wi.dot(normal).abs / pdf
        end
      end
    end

    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::REFLECTION)
    color += specular(ray, hit, bsdf, recursion_depth, BxDFType::TRANSMISSION)

    # Sample the background
    sample = bsdf.sample_f(wo, BxDFType::ALL & ~BxDFType::SPECULAR)
    if sample
      f, wi, bsdf_pdf, sampled_type = sample
      weight = 1.0
      unless sampled_type & BxDFType::SPECULAR
        light_pdf = 1.0 / Math::PI
        return color if light_pdf == 0.0
        weight = power_heuristic(1, light_pdf, 1, bsdf_pdf)
      end

      ray = Ray.new(point, wi)
      unless @scene.fast_hit(ray)
        li = @scene.background.get(ray)
        color += f * li * wi.dot(normal).abs * weight / bsdf_pdf
      end
    end

    color
  end
end
