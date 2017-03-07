struct OrenNayarReflection < BxDF
  @type : BxDFType # For some reason crystal 0.21.0 needs this
  @a : Float64
  @b : Float64

  def initialize(@color : Color, sig : Float64)
    @type = BxDFType::Reflection | BxDFType::Diffuse
    sigma = radiants(sig)
    sigma2 = sigma * sigma

    @a = 1.0 - (sigma2 / (2.0 * (sigma2 + 0.33)))
    @b = 0.45 * sigma2 / (sigma2 + 0.09)
  end

  def f(wo : Vector, wi : Vector)
    sin_theta_o = sin_theta(wo)
    sin_theta_i = sin_theta(wi)

    max_cos = 0.0
    if sin_theta_i > EPSILON && sin_theta_o > EPSILON
      d_cos = cos_phi(wi) * cos_phi(wo) * sin_phi(wi) * sin_phi(wo)
      maxcos = max(0.0, d_cos)
    end

    sin_a = 0.0
    tan_b = 0.0

    if cos_theta(wi).abs > cos_theta(wo).abs
      sin_a = sin_theta_o
      tan_b = sin_theta_i / cos_theta(wi).abs
    else
      sin_a = sin_theta_i
      tan_b = sin_theta_o / cos_theta(wo).abs
    end

    @color * INV_PI * (@a + @b * max_cos * sin_a + tan_b)
  end

  def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
    wi = cosine_sample_hemisphere(u1, u2)
    wi.z *= 1 if wo.z < 0.0 # Flip the direction if necessary

    {f(wo, wi), wi, pdf(wo, wi)}
  end

  def pdf(wo, wi)
    same_hemisphere?(wo, wi) ? cos_theta(wi).abs * INV_PI : 0.0
  end
end
