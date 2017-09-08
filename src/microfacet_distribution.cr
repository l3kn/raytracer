abstract class MicrofacetDistribution
  # Probability density of a microfacet
  # to be oriented with the normal wi
  abstract def d(wh : Vector) : Float64
  abstract def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Vector, Float64)
  abstract def pdf(wo : Vector, wi : Vector) : Float64
end

# Distribution with an exponential falloff
# in the distribution of surface normals
class MicrofacetDistribution::Blinn < MicrofacetDistribution
  @exponent : Float64

  def initialize(exponent : Float64)
    @exponent = min(exponent, 1000.0)
  end

  def d(wh : Vector) : Float64
    cos_theta_h = cos_theta(wh).abs
    (@exponent + 2) * INV_TWOPI * (cos_theta_h ** @exponent)
  end

  def sample_f(wo, u1, u2)
    cos_theta = u1 ** (1.0 / (@exponent + 1))
    sin_theta = Math.sqrt(max(0.0, 1.0 - cos_theta * cos_theta))

    phi = u2 * TWOPI

    wh = Vector.spherical_direction(sin_theta, cos_theta, phi)
    wh = -wh unless same_hemisphere?(wo, wh)

    {
      -wo + wh * 2.0 * wo.dot(wh),
      wo.dot(wh) > 0.0 ? blinn_pdf(cos_theta, wo, wh) : 0.0
    }
  end

  def pdf(wo, wi)
    wh = (wo + wi).normalize
    cos_theta = cos_theta(wh).abs

    wo.dot(wh) > 0.0 ? blinn_pdf(cos_theta, wo, wh) : 0.0
  end

  private def blinn_pdf(cos_theta, wo, wh)
    ((@exponent + 1) * (cos_theta ** @exponent)) /
      (2.0 * FOURPI * wo.dot(wh))
  end
end

struct BxDF::Microfacet < BxDF
  @type : Type # For some reason crystal 0.21.0 needs this
  
  def initialize(@color : Color, @fresnel : Fresnel, @distribution : MicrofacetDistribution)
    @type = Type::Reflection | Type::Glossy
  end

  def f(wo : Vector, wi : Vector) : Color
    cos_theta_o = cos_theta(wo).abs
    cos_theta_i = cos_theta(wi).abs

    if cos_theta_i == 0.0 || cos_theta_o == 0.0
      return Color::BLACK
    end

    wh = (wo + wi).normalize
    cos_theta_h = wi.dot(wh)

    f = @fresnel.evaluate(cos_theta_h)

    (@color * @distribution.d(wh) * g(wo, wi, wh) * f) /
      (4.0 * cos_theta_i * cos_theta_o)
  end

  # Geometric attenuation
  def g(wo : Vector, wi : Vector, wh : Vector) : Float64
    n_dot_wo = cos_theta(wo).abs
    n_dot_wi = cos_theta(wi).abs
    n_dot_wh = cos_theta(wh).abs

    wo_dot_wh = wo.dot(wh).abs

    min(
      1.0,
      min(
        2.0 * n_dot_wh * n_dot_wo / wo_dot_wh,
        2.0 * n_dot_wh * n_dot_wi / wo_dot_wh
      )
    )
  end

  def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
    wi, pdf = @distribution.sample_f(wo, u1, u2)

    if same_hemisphere?(wo, wi)
      {f(wo, wi), wi, pdf}
    else
      {Color::BLACK, wi, 0.0}
    end
  end

  def pdf(wo, wi)
    if same_hemisphere?(wo, wi)
      @distribution.pdf(wo, wi)
    else
      0.0
    end
  end
end

class Material::Microfacet < Material
  def initialize(@texture : Texture, @fresnel : Fresnel, @distribution : MicrofacetDistribution)
  end

  def initialize(color : Color, @fresnel : Fresnel, @distribution : MicrofacetDistribution)
    @texture = Texture::Constant.new(color)
  end

  def bsdf(hit)
    bxdf = BxDF::Microfacet.new(@texture.value(hit), @fresnel, @distribution)
    BSDF::Single.new(bxdf, hit.normal)
  end
end
