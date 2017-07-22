abstract class Material
  abstract def bsdf(hit : HitRecord) : BSDF
end

class Material::Glass < Material
  def initialize(@ior : Float64, @texture_reflected : Texture, @texture_transmitted : Texture)
  end

  def initialize(@ior : Float64, color_reflected = Color::WHITE, color_transmitted = Color::WHITE)
    @texture_reflected = ConstantTexture.new(color_reflected)
    @texture_transmitted = ConstantTexture.new(color_transmitted)
  end

  def bsdf(hit)
    bxdfs = [
      BxDF::SpecularReflection.new(
        @texture_reflected.value(hit),
        Fresnel::Dielectric.new(1.0, @ior)
      ).as(BxDF),
      BxDF::SpecularTransmission.new(
        @texture_transmitted.value(hit),
        1.0, @ior
      ).as(BxDF),
    ]
    BSDF::Multi.new(bxdfs, hit.normal)
  end
end

class Material::Matte < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = BxDF::LambertianReflection.new(@texture.value(hit)).as(BxDF)
    BSDF::Single.new(bxdf, hit.normal)
  end
end

class Material::OrenNayar < Material
  def initialize(@texture : Texture, @sig : Float64); end

  def initialize(color : Color, @sig : Float64)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = BxDF::OrenNayarReflection.new(@texture.value(hit), @sig).as(BxDF)
    BSDF::Single.new(bxdf, hit.normal)
  end
end

class Material::Mirror < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    bxdf = BxDF::SpecularReflection.new(@texture.value(hit), Fresnel::NoOp.new).as(BxDF)
    BSDF::Single.new(bxdf, hit.normal)
  end
end

class Material::DiffuseLight < Material
  def initialize(@texture : Texture); end

  def initialize(color : Color)
    @texture = ConstantTexture.new(color)
  end

  def bsdf(hit)
    BSDF::Emissive.new(@texture.value(hit), hit.normal)
  end
end
