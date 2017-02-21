abstract class Material
  abstract def bsdf(hit : HitRecord) : BSDF
end

class GlassMaterial < Material
  def initialize(@color_reflected : Color, @color_transmitted : Color, @ior : Float64)
  end

  def bsdf(hit)
    bxdfs = [
      SpecularReflection.new(@color_reflected, FresnelDielectric.new(1.0, @ior)).as(BxDF),
      SpecularTransmission.new(@color_transmitted, 1.0, @ior).as(BxDF)
    ]
    MultiBSDF.new(bxdfs, hit.normal)
  end
end

class CheckerMaterial < Material
  def initialize(@m1 : Material, @m2 : Material, @size = 10)
  end

  def bsdf(hit)
    u = (hit.u * @size).to_i % 2
    v = (hit.v * @size).to_i % 2

    if (u + v).even?
      @m1.bsdf(hit)
    else
      @m2.bsdf(hit)
    end
  end
end

class MatteMaterial < Material
  def initialize(@color : Color)
  end

  def bsdf(hit)
    bxdf = LambertianReflection.new(@color).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class OrenNayarBSDF < Material
  def initialize(@color : Color, @sig : Float64)
  end

  def bsdf(hit)
    bxdf = OrenNayarReflection.new(@color, @sig).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class MirrorMaterial < Material
  def initialize(@color : Color)
  end

  def bsdf(hit)
    bxdf = SpecularReflection.new(@color, FresnelNoOp.new).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class DiffuseLightMaterial < Material
  def initialize(@color : Color)
  end

  def bsdf(hit)
    EmissiveBSDF.new(@color, hit.normal)
  end
end
