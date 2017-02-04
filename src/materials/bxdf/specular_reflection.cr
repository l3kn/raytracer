class SpecularReflection < BxDF
  def initialize(@color : Color, @fresnel : Fresnel)
    super(BxDFType::Reflection)
  end

  def f(wo : Vector, wi : Vector)
    0.0
  end

  def sample_f(wo : Vector)
    wi = Vector.new(-wo.x, -wo.y, wo.z)
    albedo = @color * @fresnel.evaluate(cos_theta(wo)) / cos_theta(wi).abs
    # puts albedo
    albedo = Color.new(1.0)

    {albedo, wi}
  end
end
