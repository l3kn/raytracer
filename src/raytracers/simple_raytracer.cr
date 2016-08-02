require "../raytracer"

class SimpleRaytracer < Raytracer
  def initialize(width, height, world, camera, samples, @debug = false)
    super(width, height, world, camera, samples)
  end

  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      if @debug
        (hit.normal + Vec3.new(1.0)) / 2
      else
        scatter = hit.material.scatter(ray, hit)
        if scatter && recursion_level < RECURSION_LIMIT
          scatter.albedo * color(scatter.ray, world, recursion_level + 1)
        else
          Vec3.new(0.0)
        end
      end
    else
      # "Sky" color
      t = 0.5 * (ray.direction.normalize.y + 1.0)
      Vec3.new(1.0)*(1.0 - t) + Vec3.new(0.5, 0.7, 1.0)*t
    end
  end
end
