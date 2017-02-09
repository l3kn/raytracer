class SpecularReflection < BxDF
  def initialize(@color : Color, @fresnel : Fresnel)
    super(BxDFType::Reflection | BxDFType::Specular)
  end

  def f(wo : Vector, wi : Vector)
    Color::BLACK
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    wi = Vector.new(-wo.x, -wo.y, wo.z)
    albedo = @color * @fresnel.evaluate(cos_theta(wo)) / cos_theta(wi).abs

    {@color, wi, 1.0}
  end
end

