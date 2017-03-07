abstract class Fresnel
  abstract def evaluate(cos_i : Float64) : Float64
end

class FresnelConductor < Fresnel
  def initialize(@eta : Float64, @k : Float64); end

  def evaluate(cos_i : Float64)
    cos_i = cos_i.abs
    tmp_f = (@eta * @eta + @k * @k)
    tmp = tmp_f * cos_i * cos_i
    r_parallel2 =
      (tmp - (2.0 * @eta * cos_i) + 1.0) /
      (tmp + (2.0 * @eta * cos_i) + 1.0)
    r_perpendicular2 =
      (tmp_f - (2.0 * @eta * cos_i) + cos_i * cos_i) /
      (tmp_f + (2.0 * @eta * cos_i) + cos_i * cos_i)

    (r_parallel2 + r_perpendicular2) * 0.5
  end
end

class FresnelDielectric < Fresnel
  def initialize(@eta_i : Float64, @eta_t : Float64); end

  def evaluate(cos_i : Float64)
    cos_i = clamp(cos_i, -1.0, 1.0)

    entering = cos_i > 0.0
    eta_i, eta_t = entering ? {@eta_i, @eta_t} : {@eta_t, @eta_i}

    # Snells law
    sin_t = eta_i / eta_t * Math.sqrt(max(0.0, 1.0 - cos_i * cos_i))

    if sin_t >= 1.0 # Total internal reflection
      1.0
    else
      cos_t = Math.sqrt(max(0.0, 1.0 - sin_t * sin_t))
      cos_i = cos_i.abs

      r_parallel = 
        ((eta_t * cos_i) - (eta_i * cos_t)) /
        ((eta_t * cos_i) + (eta_i * cos_t))
      r_perpendicular =
        ((eta_i * cos_i) - (eta_t * cos_t)) /
        ((eta_i * cos_i) + (eta_t * cos_t))

      (r_parallel * r_parallel + r_perpendicular * r_perpendicular) * 0.5
    end
  end
end

class FresnelNoOp < Fresnel
  def evaluate(cos_i)
    1.0
  end
end
