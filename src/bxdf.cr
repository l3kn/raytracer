enum BxDFType
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

# TODO: Clean this up,
# this is only a hack to get bxdf materials working
class BxDF < Material
  getter type : BxDFType

  # TODO: Clean this up,
  # this is only a hack to get bxdf materials working
  def scatter(ray : Ray, hit : HitRecord)
    foo = ONB.from_w(hit.normal)

    albedo, wi_ = sample_f(foo.world_to_local(ray.direction * -1.0))
    wi = foo.local_to_world(wi_)

    ScatterRecord.new(albedo, Ray.new(hit.point + wi * 0.001, wi))
  end

  def initialize(@type)
  end

  def matches_flags(other : BxDFType)
    (@type & other) == @type
  end

  def f(wo : Vector, wi : Vector) : Float64
    0.0
  end

  # used for BxDFs where the usage of f(wo, wi)
  # is not practicable, e.g. for perfectly specular surfaces
  def sample_f(wo : Vector) : Tuple(Color, Vector)
    {Color.new(0.0), Vector.z}
  end

  # hemispherical-directional reflectance
  def rho(wo : Vector, samples) : Float64
    0.0
  end

  # hemispherical-hemispherical reflectance
  def rho(samples) : Float64
    0.0
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
    # TODO:
    # @type = @brdf.type ^ (BxDFType::Reflection, BxDFType::Transmission)
    @type = @brdf.type
  end

  def f(wo : Vector, wi : Vector) : Float64
    # Convert an incoming vector to the other hemisphere,
    # because we are using a special coordinate system,
    # we only need to swap the z value to do this
    @brdf.f(wo, wi.xy_z)
  end
end

class ScaledBxDF < BxDF
  def initialize(@bxdf : BxDF, @scale : Float64)
    @type = @bxdf.type
  end

  def f(wo : Vector, wi : Vector) : Float64
    @bxdf.f(wo, wi) * @scale
  end
end
