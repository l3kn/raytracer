class Integrator
  def initialize(@scene : Scene)
  end

  def color(ray, hit, recursion_depth)
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

    @scene.lights.each do |light|
      wi, li, visibility, pdf = light.sample_l(point)
      f = hit.material.bsdf.f(hit, wo, wi, BxDFType::All)

      if visibility.unoccluded?(@scene)
        color += f * li * wi.dot(normal).abs / pdf
      end
    end

    # BEGIN: Background lighting
    onb = ONB.from_w(normal)
    wi = onb.local(random_cosine_direction)
    foo = Ray.new(point, wi)

    unless @scene.fast_hit(foo)
      f = hit.material.bsdf.f(hit, wo, wi, BxDFType::All)
      # TODO: Bad try at calculating a pdf for the infinite background light
      color += @scene.background.get(foo) * f * Math::PI  # * wi.dot(normal).abs * (2.0 * Math::PI)
    end
    # END: Background lighting

    color += specular_reflect(ray, hit, bsdf, recursion_depth)
    color += specular_transmit(ray, hit, bsdf, recursion_depth)

    if color.r >= 1.0
      # puts "===="
      # puts old_color
      # puts color
    end

    color
  end

  def specular_reflect(ray, hit, bsdf, recursion_depth)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    color, wi, pdf = bsdf.sample_f(hit, wo, BxDFType::Reflection | BxDFType::Specular)

    if color.black? || wi.dot(normal).abs == 0.0
      Color::BLACK
    else
      new_ray = Ray.new(point, wi)
      new_hit = @scene.hit(new_ray)
      if new_hit
        li = color(new_ray, new_hit, recursion_depth - 1)
      else
        li = @scene.background.get(new_ray)
      end
      li * color * wi.dot(normal).abs / pdf
    end
  end

  def specular_transmit(ray, hit, bsdf, recursion_depth)
    wo = -ray.direction
    point = hit.point
    normal = hit.normal

    color, wi, pdf = bsdf.sample_f(hit, wo, BxDFType::Transmission | BxDFType::Specular)

    if color.black? || wi.dot(normal).abs == 0.0
      Color::BLACK
    else
      new_ray = Ray.new(point, wi)
      new_hit = @scene.hit(new_ray)
      if new_hit
        li = color(new_ray, new_hit, recursion_depth - 1)
      else
        li = @scene.background.get(new_ray)
      end
      li * color * wi.dot(normal).abs / pdf
    end
  end
end
