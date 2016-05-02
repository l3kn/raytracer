class Material
  def scatter(ray : Ray, hit : Intersection)
    nil
  end

  def emitted(point)
    Vec3.new(0.0)
  end
end
