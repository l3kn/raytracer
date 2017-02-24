require "../fresnel"

struct SpecularReflection < BxDF
  @type : Int32 # For some reason crystal 0.21.0 needs this

  def initialize(@color : Color, @fresnel : Fresnel)
    @type = BxDFType::REFLECTION | BxDFType::SPECULAR
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

struct SpecularTransmission < BxDF
  @type : Int32 # For some reason crystal 0.21.0 needs this

  def initialize(@color : Color, @eta_i : Float64, @eta_t : Float64)
    @type = BxDFType::TRANSMISSION | BxDFType::SPECULAR
    @fresnel = FresnelDielectric.new(@eta_i, @eta_t)
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    entering = cos_theta(wo) > 0.0
    ei, et = entering ? {@eta_i, @eta_t} : {@eta_t, @eta_i}

    wi = Normal.new(0.0, 0.0, 1.0).face_forward(wo).refract(wo, ei / et)

    if wi
      ft = @color * (1.0 - @fresnel.evaluate(cos_theta(wi)))
      return { ft / cos_theta(wi).abs, wi, 1.0 }
    else
      return { Color::BLACK, Vector.x, 0.0 }
    end
  end

  def pdf
    0.0
  end

  def f(wo, wi)
    Color::BLACK
  end
end
