abstract class Material
  abstract def bsdf(point : Point, normal : Normal, u : Float64, v : Float64) : BSDF
end

class GlassMaterial < Material
  def initialize(@texture_reflected : Texture, @texture_transmitted : Texture, @ior : Float64)
  end

  def initialize(color_reflected : Color, color_transmitted : Color, @ior : Float64)
    @texture_reflected = ConstantTexture.new(color_reflected)
    @texture_transmitted = ConstantTexture.new(color_transmitted)
  end

  def bsdf(point, normal, u, v)
    bxdfs = [
      SpecularReflection.new(@texture_reflected.value(point, normal, u, v),
                             FresnelDielectric.new(1.0, @ior)).as(BxDF),
      SpecularTransmission.new(@texture_transmitted.value(point, normal, u, v),
                               1.0, @ior).as(BxDF)
    ]
    MultiBSDF.new(bxdfs, normal)
  end
end

class CheckerMaterial < Material
  def initialize(@m1 : Material, @m2 : Material, @size = 10); end

  def bsdf(point, normal, u, v)
    ui = (u * @size).to_i % 2
    vi = (v * @size).to_i % 2
    (ui + vi).even? ? @m1.bsdf(point, normal, u, v) : @m2.bsdf(point, normal, u, v)
  end
end

class MatteMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(point, normal, u, v)
    bxdf = LambertianReflection.new(@texture.value(point, normal, u, v)).as(BxDF)
    SingleBSDF.new(bxdf, normal)
  end
end

class OrenNayarMaterial < Material
  def initialize(@texture : Texture, @sig : Float64); end

  def initialize(color : Color, @sig : Float64)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(point, normal, u, v)
    bxdf = OrenNayarReflection.new(@texture.value(point, normal, u, v), @sig).as(BxDF)
    SingleBSDF.new(bxdf, normal)
  end
end

class MirrorMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(point, normal, u, v)
    bxdf = SpecularReflection.new(@texture.value(point, normal, u, v), FresnelNoOp.new).as(BxDF)
    SingleBSDF.new(bxdf, normal)
  end
end

class DiffuseLightMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(point, normal, u, v)
    EmissiveBSDF.new(@texture.value(point, normal, u, v), normal)
  end
end
