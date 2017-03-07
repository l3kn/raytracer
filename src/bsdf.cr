abstract struct BSDF
  # Number of components matching the given flag
  abstract def num_components(flags = BxDFType::All) : Int32
  abstract def f(wo_world : Vector, wi_world : Vector, flags : BxDFType) : Color
  abstract def sample_f(wo_world : Vector, flags : BxDFType) : Tuple(Color, Vector, Float64, Int32)?
  abstract def pdf(wo : Vector, wi : Vector, flags = BxDFType::All) : Float64
  abstract def emitted(wo_world) : Color

  def matches_flags?(flags : BxDFType)
    num_components(flags) > 0
  end

  def diffuse?
    matches_flags?(BxDFType::Diffuse | BxDFType::Reflection | BxDFType::Transmission)
  end

  def glossy?
    matches_flags?(BxDFType::Glossy | BxDFType::Reflection | BxDFType::Transmission)
  end
end

struct MultiBSDF < BSDF
  property bxdfs : Array(BxDF)

  def initialize(@bxdfs, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDFType::All)
    @bxdfs.count(&.matches_flags?(flags))
  end

  def f(wo_world : Vector, wi_world : Vector, flags : BxDFType) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    # Both vectors outside of the object ? ingnore BTDFs : ignore BRDFs
    # NOTE: "~" = complement
    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags &= ~BxDFType::Transmission
    else
      flags &= ~BxDFType::Reflection
    end

    color = Color::BLACK

    @bxdfs.each do |bxdf|
      color += bxdf.f(wo, wi) if bxdf.matches_flags?(flags)
    end

    color
  end

  def sample_f(wo_world : Vector, flags : BxDFType) : Tuple(Color, Vector, Float64, BxDFType)?
    matching = @bxdfs.select(&.matches_flags?(flags))
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
    if !(bxdf.type.specular?) && matching.size > 1
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
    if bxdf.type.specular?
      {color, wi_world, pdf, bxdf.type}
    else
      if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
        flags = flags & ~BxDFType::Transmission
      else
        flags = flags & ~BxDFType::Reflection
      end

      color = Color::BLACK
      @bxdfs.each do |bxdf_|
        color += bxdf_.f(wo, wi) if bxdf_.matches_flags?(flags) && bxdf != bxdf_
      end

      {color, wi_world, pdf, bxdf.type}
    end
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDFType::All) : Float64
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    pdf = 0.0
    matching = @bxdfs.select(&.matches_flags?(flags))
    matching.each do |bxdf|
      pdf += bxdf.pdf(wo, wi)
    end

    matching.size == 0 ? 0.0 : pdf / matching.size
  end

  def emitted(wo_world)
    Color::BLACK
  end
end

struct SingleBSDF < BSDF
  property bxdf : BxDF

  def initialize(@bxdf, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDFType::All)
    @bxdf.matches_flags?(flags) ? 1 : 0
  end

  def f(wo_world : Vector, wi_world : Vector, flags : BxDFType) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags &= ~BxDFType::Transmission
    else
      flags &= ~BxDFType::Reflection
    end

    @bxdf.matches_flags?(flags) ? @bxdf.f(wo, wi) : Color::BLACK
  end

  def sample_f(wo_world : Vector, flags : BxDFType) : Tuple(Color, Vector, Float64, BxDFType)?
    return nil unless @bxdf.matches_flags?(flags)

    wo = @world_to_local.world_to_local(wo_world).normalize

    color, wi, pdf = @bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = @world_to_local.local_to_world(wi)
    {color, wi_world, pdf, @bxdf.type}
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDFType::All)
    return 0.0 unless @bxdf.matches_flags?(flags)
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize
    @bxdf.pdf(wo, wi)
  end

  def emitted(wo_world)
    Color::BLACK
  end
end

struct EmissiveBSDF < BSDF
  def initialize(@emitted : Color, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDFType::All)
    0
  end

  def f(wo_world, wi_world, flags)
    Color::BLACK
  end

  def pdf(wo, wi, flags = BxDFType::All)
    0.0
  end

  def sample_f(wo_world, flags)
    nil
  end

  def emitted(wo_world) : Color
    # Only emit light on one side
    @normal.dot(wo_world) > 0.0 ? @emitted : Color::BLACK
  end
end
