class SpecularReflection < BxDF
  def initialize(@color : Color, @fresnel : Fresnel)
    super(BxDFType::Reflection | BxDFType::Specular)
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    wi = Vector.new(-wo.x, -wo.y, wo.z)
    ft = @color * @fresnel.evaluate(cos_theta(wi))
    { ft / cos_theta(wi).abs, wi, 1.0 }
  end

  def pdf
    0.0
  end

  def f(wo, wi)
    Color::BLACK
  end
end
