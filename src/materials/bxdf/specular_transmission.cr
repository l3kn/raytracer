class SpecularTransmission < BxDF
  def initialize(@color : Color, @eta_i : Float64, @eta_t : Float64)
    super(BxDFType::Transmission | BxDFType::Specular)
    @fresnel = FDielectric.new(@eta_i, @eta_t)
  end

  def f(wo : Vector, wi : Vector)
    Color::BLACK
  end

  def sample_f(wo : Vector) : Tuple(Color, Vector, Float64)
    entering = cos_theta(wo) > 0.0
    ei, et = entering ? {@eta_i, @eta_t} : {@eta_t, @eta_i}

    sin_i_2 = sin_theta_2(wo)
    eta = ei / et
    sin_t_2 = eta * eta * sin_i_2

    cos_t = Math.sqrt(max(0.0, 1.0 - sin_t_2))
    cos_t = -cos_t if entering

    sin_t_over_sin_i = eta
    wi = Vector.new(
      sin_t_over_sin_i * -wo.x,
      sin_t_over_sin_i * -wo.y,
      cos_t
    )

    # Total internal reflection
    return {Color.new(0.0), wi, 1.0} if sin_t_2 >= 1.0

    f = @fresnel.evaluate(cos_theta(wo))

    albedo = (Color.new(1.0-f)) * @color / cos_theta(wi).abs * (et*et)/(ei*ei) 

    {@color, wi, 1.0}
  end
end
