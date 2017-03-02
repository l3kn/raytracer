class NormalRaytracer < BaseRaytracer
  def cast_ray(ray)
    hit = @scene.hit(ray)
    if hit.nil?
      @scene.background.get(ray)
    else
      Color.new(
        (1.0 + hit.normal.x) * 0.5,
        (1.0 + hit.normal.y) * 0.5,
        (1.0 + hit.normal.z) * 0.5,
      )
    end
  end
end
