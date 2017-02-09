class Integrator
  def self.color(scene, ray, hit, recursion_depth, renderer)
    if recursion_depth <= 0
      return Color::BLACK
    end

    color = Color::BLACK

    # Compute emitted and reflected light at intersection
    bsdf = hit.material.bsdf
    point = hit.point
    normal = hit.normal

    wo = -ray.direction


    # TODO: Implement emissive materials
    # color += hit.emitted

    scene.lights.each do |light|
      wi, li, visibility, pdf = light.sample_l(point)
      f = hit.material.bsdf.f(hit, wo, wi, BxDFType::All)

      if visibility.unoccluded?(scene)
        color += f * li * wi.dot(normal).abs / pdf
      end
    end

    color += specular_reflect(ray, hit, bsdf, renderer, recursion_depth)
    color += specular_transmit(ray, hit, bsdf, renderer, recursion_depth)

    color
  end

  def self.specular_reflect(ray, hit, bsdf, renderer, recursion_depth)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    color, wi, pdf = bsdf.sample_f(hit, wo, BxDFType::Reflection | BxDFType::Specular)

    if color.black? || wi.dot(normal).abs == 0.0
      Color::BLACK
    else
      li = renderer.cast_ray(Ray.new(point, wi), recursion_depth - 1)
      li * color * wi.dot(normal).abs / pdf
    end
  end

  def self.specular_transmit(ray, hit, bsdf, renderer, recursion_depth)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    color, wi, pdf = bsdf.sample_f(hit, wo, BxDFType::Transmission | BxDFType::Specular)

    if color.black? || wi.dot(normal).abs == 0.0
      Color::BLACK
    else
      li = renderer.cast_ray(Ray.new(point, wi), recursion_depth - 1)
      li * color * wi.dot(normal).abs / pdf
    end
  end
end
