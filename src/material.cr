abstract class Material
  property emitted : Color
  @emitted = Color::BLACK

  def f(hit : HitRecord, wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    Color::BLACK
  end

  def sample_f(hit : HitRecord, wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64)?
    nil
  end

  def emitted(hit : HitRecord, wo_world) : Color
    Color::BLACK
  end
end

class MultiMaterial < Material
  property bxdfs : Array(BxDF)

  def initialize(@bxdfs)
  end

  def f(hit : HitRecord, wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)
    wi = onb.world_to_local(wi_world)

    # TODO: Are these already normalized?
    wo = wo / wo.length
    wi = wi / wi.length

    # If both vectors are outside of the object, ignore the BTDFs,
    # otherwise ignore the BRDFs ("~" = bitwise negate)
    if wi_world.dot(normal) * wo_world.dot(normal) > 0
      flags = flags & ~BxDFType::Transmission
    else
      flags = flags & ~BxDFType::Reflection
    end

    color = Color::BLACK

    @bxdfs.each do |bxdf|
      color += bxdf.f(wo, wi) if bxdf.matches_flags(flags)
    end

    color
  end

  def sample_f(hit : HitRecord, wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64)?
    matching = @bxdfs.select(&.matches_flags(flags))
    return nil if matching.size == 0

    # Sample a random matching BxDF
    bxdf = matching.sample

    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)

    # TODO: Are these already normalized?
    wo = wo / wo.length

    color, wi, pdf = bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = onb.local_to_world(wi)

    # Compute the overall pdf of all matching BxDFs
    # 
    # If the sampled bxdf is specular,
    # it means that its pdf is a delta distribution => pdf = 1.0
    # and it would be incorrect to add other pdfs onto it
    if !(bxdf.type & BxDFType::Specular) && matching.size > 1
      matching.each do |bxdf_|
        pdf += bxdf_.pdf(wo, wi) if bxdf_ != bxdf
      end
    end

    pdf /= matching.size

    # Compute the value of the sampled bxdf for the sampled directions.
    #
    # If the sampled bxdf is specular,
    # just return the results we got from sample_f
    # because f would just return black (delta distribution!).
    # This is pretty much a copy of BSDF.f(...)
    # but bc/ the mapped directions are already known,
    # this saves some time
    if (bxdf.type & BxDFType::Specular)
      {color, wi_world, pdf}
    else
      if wi_world.dot(normal) * wo_world.dot(normal) > 0
        flags = flags & ~BxDFType::Transmission
      else
        flags = flags & ~BxDFType::Reflection
      end

      color = Color::BLACK
      @bxdfs.each do |bxdf_|
        color += bxdf_.f(wo, wi) if bxdf_.matches_flags(flags) && bxdf != bxdf_
      end

      {color, wi_world, pdf}
    end
  end

  def pdf(wo : Vector, wi : Vector, flags = BxDFType::All)
    pdf = 0.0
    matching = @bxdfs.filter(&.matches_flags(flags))
    matching.each do |bxdf|
      pdf += bxdf.pdf(wo, wi)
    end

    matching.size == 0 ? 0.0 : pdf / matching.size
  end
end

class SingleMaterial < Material
  property bxdf : BxDF

  def initialize(@bxdf)
  end

  def f(hit : HitRecord, wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)
    wi = onb.world_to_local(wi_world)

    # TODO: Are these already normalized?
    wo = wo / wo.length
    wi = wi / wi.length

    # If both vectors are outside of the object,
    # ignore the BTDFs,
    # otherwise ignore the BRDFs
    # "~" = complement
    if wi_world.dot(normal) * wo_world.dot(normal) > 0
      flags = flags & ~BxDFType::Transmission
    else
      flags = flags & ~BxDFType::Reflection
    end

    if @bxdf.matches_flags(flags)
      @bxdf.f(wo, wi)
    else
      Color::BLACK
    end
  end

  def sample_f(hit : HitRecord, wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64)?
    return nil unless @bxdf.matches_flags(flags)

    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)

    # TODO: Are these already normalized?
    wo = wo / wo.length

    color, wi, pdf = @bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = onb.local_to_world(wi)
    {color, wi_world, pdf}
  end

  def pdf(wo : Vector, wi : Vector, flags = BxDFType::All)
    return 0.0 unless @bxdf.matches_flags(flags)
    @bxdf.pdf(wo, wi)
  end
end

class GlassMaterial < MultiMaterial
  def initialize(color_reflected, color_transmitted, ior)
    @bxdfs = [
      SpecularReflection.new(color_reflected, FresnelDielectric.new(1.0, ior)).as(BxDF),
      SpecularTransmission.new(color_transmitted, 1.0, ior).as(BxDF)
    ]
  end
end

class MatteMaterial < SingleMaterial
  def initialize(color)
    super(LambertianReflection.new(color).as(BxDF))
  end
end

class OrenNayarMaterial < SingleMaterial
  def initialize(color, sig)
    super(OrenNayarReflection.new(color, sig).as(BxDF))
  end
end

class MirrorMaterial < SingleMaterial
  def initialize(color)
    super(SpecularReflection.new(color, FresnelNoOp.new).as(BxDF))
  end
end

# require "../material"
# require "../texture"

class DiffuseLightMaterial < Material
  def initialize(@emitted : Color)
  end
end
