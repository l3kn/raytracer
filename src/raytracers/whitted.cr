class WhittedRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    color = Color::BLACK
    return color if recursion_depth <= 0

    # Compute emitted and reflected light at intersection
    point = hit.point
    normal = hit.normal
    bsdf = hit.material.bsdf(hit)

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
    color += estimate_background(hit, bsdf, wo, BxDFType::ALL & ~BxDFType::SPECULAR)

    color
  end
end
