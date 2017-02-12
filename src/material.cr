abstract class Material
  property bxdfs : Array(BxDF)

  def initialize(@bxdfs)
  end

  # Old scatter:
  # def scatter(ray : Ray, hit : HitRecord)
  #   foo = ONB.from_w(hit.normal)

  #   wo = foo.world_to_local(ray.direction * -1.0)

  #   albedo, wi_ = sample_f(foo.world_to_local(ray.direction * -1.0))
  #   wi = foo.local_to_world(wi_)

  #   albedo *= cos_theta(wi_)

  #   ScatterRecord.new(albedo, Ray.new(hit.point + wi * 0.001, wi))
  # end


  def f(hit : HitRecord, wo_world : Vector, wi_world : Vector, flags : Int32) : Color

    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)
    wi = onb.world_to_local(wi_world)

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

    color = Color::BLACK

    @bxdfs.each do |bxdf|
      color += bxdf.f(wo, wi) if bxdf.matches_flags(flags)
    end

    color
  end

  def sample_f(hit : HitRecord, wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64)
    matching = @bxdfs.select(&.matches_flags(flags))
    return {Color.new(0.0), Vector.z, 0.0} if matching.size == 0

    # Sample a random matching BxDF
    bxdf = matching.sample

    normal = hit.normal
    onb = ONB.from_w(normal)
    wo = onb.world_to_local(wo_world)
    wo = wo / wo.length

    color, wi, pdf = bxdf.sample_f(wo)
    return {Color.new(0.0), Vector.z, 0.0} if pdf == 0.0

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
      @bxdfs.each do |bxdf|
        color += bxdf.f(wo, wi) if bxdf.matches_flags(flags)
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

class GlassMaterial < Material
  def initialize(color_reflected, color_transmitted, ior)
    @bxdfs = [
      SpecularReflection.new(color_reflected, FresnelDielectric.new(1.0, ior)).as(BxDF),
      SpecularTransmission.new(color_transmitted, 1.0, ior).as(BxDF)
    ]
  end
end

class MatteMaterial < Material
  def initialize(color)
    @bxdfs = [
      LambertianReflection.new(color).as(BxDF),
    ]
  end
end

class MirrorMaterial < Material
  def initialize(color)
    @bxdfs = [
      SpecularReflection.new(color, FresnelNoOp.new).as(BxDF),
    ]
  end
end
