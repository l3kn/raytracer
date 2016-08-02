require "../raytracer"

class DebugRaytracer < Raytracer
  def color(ray, world, recursion_level = 0)
    hit = world.hit(ray, 0.0001, 9999.9)
    if hit
      (hit.normal + Vec3.new(1.0)) / 2
    else
      Vec3.new(0.0)
    end
  end
end
