abstract struct BxDF
  @[Flags]
  enum Type
    Reflection
    Transmission

    Diffuse
    Glossy
    Specular
  end

  getter type : Type = Type::None

  def matches_flags?(other : BxDF::Type)
    (@type & other) == @type
  end

  abstract def f(wo : Vector, wi : Vector) : Color

  # Sample the hemisphere, flipping the dir if necessary
  #
  # Used for BxDFs where the usage of f(wo, wi)
  # is not practicable, e.g. for perfectly specular surfaces
  def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
    wi = cosine_sample_hemisphere(u1, u2)
    wi.z *= -1 if wo.z < 0.0 # Flip the direction if necessary

    {f(wo, wi), wi, pdf(wo, wi)}
  end

  def pdf(wo, wi)
    same_hemisphere?(wo, wi) ? cos_theta(wi).abs * INV_PI : 0.0
  end
end
