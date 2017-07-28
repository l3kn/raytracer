struct BxDF::LambertianReflection < BxDF
  @type : Type # For some reason crystal 0.21.0 needs this

  def initialize(@color : Color)
    @type = Type::Reflection | Type::Diffuse
  end

  def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
    wi = cosine_sample_hemisphere(u1, u2)
    wi.z *= -1 if wo.z < 0.0 # Flip the direction if necessary

    {f(wo, wi), wi, pdf(wo, wi)}
  end

  def f(wo : Vector, wi : Vector)
    @color * INV_PI
  end

  def pdf(wo, wi)
    same_hemisphere?(wo, wi) ? cos_theta(wi).abs * INV_PI : 0.0
  end
end
