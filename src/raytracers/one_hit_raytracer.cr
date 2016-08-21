class OneHitRaytracer < Raytracer
  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      scatter = hit.material.scatter(ray, hit)
      if scatter
        scatter.albedo
      else
        Vec3.new(0.0)
      end
    else
      @background.get(ray)
    end
  end
end
