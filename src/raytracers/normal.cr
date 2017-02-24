class NormalRaytracer < BaseRaytracer
  def color(ray, hit, recursion_depth)
    Color.new(
      (1.0 + hit.normal.x) * 0.5,
      (1.0 + hit.normal.y) * 0.5,
      (1.0 + hit.normal.z) * 0.5,
    )
  end
end
