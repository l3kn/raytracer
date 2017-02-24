abstract struct BSDF
  def f(wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    Color::BLACK
  end

  def sample_f(wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64, Int32)?
    nil
  end

  def emitted(wo_world) : Color
    Color::BLACK
  end

  def pdf(wo : Vector, wi : Vector, flags = BxDFType::ALL) : Float64
    0.0
  end
end

struct MultiBSDF < BSDF
  property bxdfs : Array(BxDF)

  def initialize(@bxdfs, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def f(wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    # If both vectors are outside of the object, ignore the BTDFs,
    # otherwise ignore the BRDFs ("~" = bitwise negate)
    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags = flags & ~BxDFType::TRANSMISSION
    else
      flags = flags & ~BxDFType::REFLECTION
    end

    color = Color::BLACK

    @bxdfs.each do |bxdf|
      color += bxdf.f(wo, wi) if bxdf.matches_flags(flags)
    end

    color
  end

  def sample_f(wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64, Int32)?
    matching = @bxdfs.select(&.matches_flags(flags))
    return nil if matching.size == 0

    # Sample a random matching BxDF
    bxdf = matching.sample

    wo = @world_to_local.world_to_local(wo_world).normalize

    color, wi, pdf = bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = @world_to_local.local_to_world(wi)

    # Compute the overall pdf of all matching BxDFs
    # 
    # If the sampled bxdf is specular,
    # it means that its pdf is a delta distribution => pdf = 1.0
    # and it would be incorrect to add other pdfs onto it
    if !(bxdf.type & BxDFType::SPECULAR) && matching.size > 1
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
    if (bxdf.type & BxDFType::SPECULAR)
      {color, wi_world, pdf, bxdf.type}
    else
      if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
        flags = flags & ~BxDFType::TRANSMISSION
      else
        flags = flags & ~BxDFType::REFLECTION
      end

      color = Color::BLACK
      @bxdfs.each do |bxdf_|
        color += bxdf_.f(wo, wi) if bxdf_.matches_flags(flags) && bxdf != bxdf_
      end

      {color, wi_world, pdf, bxdf.type}
    end
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDFType::ALL) : Float64
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    pdf = 0.0
    matching = @bxdfs.select(&.matches_flags(flags))
    matching.each do |bxdf|
      pdf += bxdf.pdf(wo, wi)
    end

    matching.size == 0 ? 0.0 : pdf / matching.size
  end
end

struct SingleBSDF < BSDF
  property bxdf : BxDF

  def initialize(@bxdf, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def f(wo_world : Vector, wi_world : Vector, flags : Int32) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    # Both vectors outside of the object ? ingnore BTDFs : ignore BRDFs
    # NOTE: "~" = complement
    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags = flags & ~BxDFType::TRANSMISSION
    else
      flags = flags & ~BxDFType::REFLECTION
    end

    @bxdf.matches_flags(flags) ? @bxdf.f(wo, wi) : Color::BLACK
  end

  def sample_f(wo_world : Vector, flags : Int32) : Tuple(Color, Vector, Float64, Int32)?
    return nil unless @bxdf.matches_flags(flags)

    wo = @world_to_local.world_to_local(wo_world).normalize

    color, wi, pdf = @bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = @world_to_local.local_to_world(wi)
    # TODO: would it be a good idea to normalize wi_world here?
    {color, wi_world, pdf, @bxdf.type}
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDFType::ALL)
    return 0.0 unless @bxdf.matches_flags(flags)
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize
    @bxdf.pdf(wo, wi)
  end
end

struct EmissiveBSDF < BSDF
  def initialize(@emitted : Color, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def emitted(wo_world) : Color
    # TODO: maybe make the light only emit to one side
    @emitted
  end
end
