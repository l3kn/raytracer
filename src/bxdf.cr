module BxDFType
  Reflection = 1
  Transmission = 2

  Diffuse = 4
  Glossy = 8
  Specular = 16
  AllTypes = Diffuse | Glossy | Specular

  AllReflection = Reflection | AllTypes
  AllTransmission = Transmission | AllTypes

  All = AllReflection | AllTransmission
end

abstract class BxDF
  getter type : Int32
  @type = 0

  def matches_flags(other : Int32)
    (@type & other) == @type
  end

  def f(wo : Vector, wi : Vector) : Color
    puts "Error: Calling f on the parent class"
    Color::BLACK
  end

  # used for BxDFs where the usage of f(wo, wi)
  # is not practicable, e.g. for perfectly specular surfaces
  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    wi = random_cosine_direction
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

class BRDFtoBTDFAdapter < BxDF
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

class ScaledBxDF < BxDF
  def initialize(@bxdf : BxDF, @scale : Float64)
    @type = @bxdf.type
  end

  def f(wo : Vector, wi : Vector) : Color
    @bxdf.f(wo, wi) * @scale
  end
end
