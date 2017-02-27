module BxDFType
  REFLECTION = 1
  TRANSMISSION = 2

  DIFFUSE = 4
  GLOSSY = 8
  SPECULAR = 16
  ALLTYPES = DIFFUSE | GLOSSY | SPECULAR

  ALLREFLECTION = REFLECTION | ALLTYPES
  ALLTRANSMISSION = TRANSMISSION | ALLTYPES

  ALL = ALLREFLECTION | ALLTRANSMISSION
end

abstract struct BxDF
  getter type : Int32 = 0

  # TODO: This should end w/ "?"
  def matches_flags(other : Int32)
    (@type & other) == @type
  end

  def f(wo : Vector, wi : Vector) : Color
    puts "Error: Calling f on the parent class"
    Color::BLACK
  end

  # used for BxDFs where the usage of f(wo, wi)
  # is not practicable, e.g. for perfectly specular surfaces
  def sample_f(wo : Vector, u1 : Float64 = rand, u2 : Float64 = rand) : Tuple(Color, Vector, Float64)
    wi = cosine_sample_hemisphere(u1, u2)
    wi.z *= 1 if wo.z < 0.0 # Flip the direction if necessary

    {f(wo, wi), wi, pdf(wo, wi)} 
  end

  def pdf(wo, wi)
    same_hemisphere?(wo, wi) ? cos_theta(wi).abs * INV_PI : 0.0
  end

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

abstract struct BRDFtoBTDFAdapter < BxDF
  def initialize(@brdf : BxDF)
    # Switch the Reflection and Transmission flags
    @type = @brdf.type ^ (BxDFType::Reflection | BxDFType::Transmission)
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    color, wi, pdf = @brdf.sample_f(wo)
    {color, Vector.new(wi.x, wi.y, -wi.z), pdf}
  end

  def f(wo : Vector, wi : Vector) : Color
    # Convert an incoming vector to the other hemisphere,
    # because we are using a special coordinate system,
    # we only need to swap the z value to do this
    @brdf.f(wo, Vector.new(wi.x, wi.y, -wi.z))
  end

  def pdf(wo : Vector, wi : Vector)
    @brdf.pdf(wo, Vector.new(wi.x, wi.y, -wi.z))
  end
end

abstract struct ScaledBxDF < BxDF
  def initialize(@bxdf : BxDF, @scale : Float64)
    @type = @bxdf.type
  end

  def f(wo : Vector, wi : Vector) : Color
    @bxdf.f(wo, wi) * @scale
  end
end
