class LambertianReflection < BxDF
  def initialize(@color : Color)
    super(BxDFType::Reflection | BxDFType::Diffuse)
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    wi = random_cosine_direction
    {f(wo, wi), wi, pdf(wo, wi)} 
  end

  def f(wo : Vector, wi : Vector)
    @color / Math::PI
  end
end
