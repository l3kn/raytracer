@[Flags]
enum BxDFType
  Reflection
  Transmission

  Diffuse
  Glossy
  Specular
end

abstract struct BxDF
  getter type : BxDFType = BxDFType::None

  def matches_flags?(other : BxDFType)
    (@type & other) == @type
  end

  abstract def f(wo : Vector, wi : Vector) : Color
  # used for BxDFs where the usage of f(wo, wi)
  # is not practicable, e.g. for perfectly specular surfaces
  abstract def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
  abstract def pdf(wo : Vector, wi : Vector) : Color

  def cos_theta(w : Vector)
    w.z
  end

  def sin_theta_2(w : Vector)
    max(0.0, 1.0 - cos_theta(w)*cos_theta(w))
  end

  def sin_theta(w : Vector)
    Math.sqrt(sin_theta_2(w))
  end

  def cos_phi(w : Vector)
    st = sin_theta(w)
    st == 0.0 ? 1.0 : clamp(w.x / st, -1.0, 1.0)
  end

  def sin_phi(w : Vector)
    st = sin_theta(w)
    st == 0.0 ? 1.0 : clamp(w.y / st, -1.0, 1.0)
  end
end
