abstract class Material
  abstract def bsdf(hit : HitRecord) : BSDF
end

class GlassMaterial < Material
  def initialize(@ior : Float64, @texture_reflected : Texture, @texture_transmitted : Texture)
  end

  def initialize(@ior : Float64, color_reflected = Color::WHITE, color_transmitted = Color::WHITE)
    @texture_reflected = ConstantTexture.new(color_reflected)
    @texture_transmitted = ConstantTexture.new(color_transmitted)
  end

  def bsdf(hit)
    bxdfs = [
      SpecularReflection.new(
        @texture_reflected.value(hit),
        Fresnel::Dielectric.new(1.0, @ior)
      ).as(BxDF),
      SpecularTransmission.new(
        @texture_transmitted.value(hit),
        1.0, @ior
      ).as(BxDF),
    ]
    MultiBSDF.new(bxdfs, hit.normal)
  end
end

class MatteMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = LambertianReflection.new(@texture.value(hit)).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class OrenNayarMaterial < Material
  def initialize(@texture : Texture, @sig : Float64); end

  def initialize(color : Color, @sig : Float64)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = OrenNayarReflection.new(@texture.value(hit), @sig).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class MirrorMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = SpecularReflection.new(@texture.value(hit), Fresnel::NoOp.new).as(BxDF)
    SingleBSDF.new(bxdf, hit.normal)
  end
end

class DiffuseLightMaterial < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    EmissiveBSDF.new(@texture.value(hit), hit.normal)
  end
end
