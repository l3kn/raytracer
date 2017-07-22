abstract struct BSDF
  record Sample, color : Color, dir : Vector, pdf : Float64, type : BxDF::Type do
    def relevant?
      !(@pdf == 0.0 || @color.black?)
    end
  end

  # Number of components matching the given flag
  abstract def num_components(flags = BxDF::Type::All) : Int32
  abstract def f(wo_world : Vector, wi_world : Vector, flags : BxDF::Type) : Color
  abstract def sample_f(wo_world : Vector, flags : BxDF::Type) : Sample?
  abstract def pdf(wo : Vector, wi : Vector, flags = BxDF::Type::All) : Float64
  abstract def emitted(wo_world) : Color

  def matches_flags?(flags : BxDF::Type)
    num_components(flags) > 0
  end

  def diffuse?
    matches_flags?(BxDF::Type::Diffuse | BxDF::Type::Reflection | BxDF::Type::Transmission)
  end

  def glossy?
    matches_flags?(BxDF::Type::Glossy | BxDF::Type::Reflection | BxDF::Type::Transmission)
  end
end

struct BSDF::Multi < BSDF
  property bxdfs : Array(BxDF)

  def initialize(@bxdfs, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDF::Type::All)
    @bxdfs.count(&.matches_flags?(flags))
  end

  def f(wo_world : Vector, wi_world : Vector, flags : BxDF::Type) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    # Both vectors outside of the object ? ingnore BTDFs : ignore BRDFs
    # NOTE: "~" = complement
    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags &= ~BxDF::Type::Transmission
    else
      flags &= ~BxDF::Type::Reflection
    end

    color = Color::BLACK

    @bxdfs.each do |bxdf|
      color += bxdf.f(wo, wi) if bxdf.matches_flags?(flags)
    end

    color
  end

  def sample_f(wo_world : Vector, flags : BxDF::Type)
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
      Sample.new(color, wi_world, pdf, bxdf.type)
    else
      if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
        flags = flags & ~BxDF::Type::Transmission
      else
        flags = flags & ~BxDF::Type::Reflection
      end

      color = Color::BLACK
      @bxdfs.each do |bxdf_|
        color += bxdf_.f(wo, wi) if bxdf_.matches_flags?(flags) && bxdf != bxdf_
      end

      Sample.new(color, wi_world, pdf, bxdf.type)
    end
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDF::Type::All) : Float64
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

struct BSDF::Single < BSDF
  property bxdf : BxDF

  def initialize(@bxdf, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDF::Type::All)
    @bxdf.matches_flags?(flags) ? 1 : 0
  end

  def f(wo_world : Vector, wi_world : Vector, flags : BxDF::Type) : Color
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize

    if wi_world.dot(@normal) * wo_world.dot(@normal) > 0
      flags &= ~BxDF::Type::Transmission
    else
      flags &= ~BxDF::Type::Reflection
    end

    @bxdf.matches_flags?(flags) ? @bxdf.f(wo, wi) : Color::BLACK
  end

  def sample_f(wo_world : Vector, flags : BxDF::Type)
    return nil unless @bxdf.matches_flags?(flags)

    wo = @world_to_local.world_to_local(wo_world).normalize

    color, wi, pdf = @bxdf.sample_f(wo)
    return nil if pdf == 0.0

    wi_world = @world_to_local.local_to_world(wi)
    Sample.new(color, wi_world, pdf, @bxdf.type)
  end

  def pdf(wo_world : Vector, wi_world : Vector, flags = BxDF::Type::All)
    return 0.0 unless @bxdf.matches_flags?(flags)
    wo = @world_to_local.world_to_local(wo_world).normalize
    wi = @world_to_local.world_to_local(wi_world).normalize
    @bxdf.pdf(wo, wi)
  end

  def emitted(wo_world)
    Color::BLACK
  end
end

struct BSDF::Emissive < BSDF
  def initialize(@emitted : Color, @normal : Normal)
    @world_to_local = ONB.from_w(@normal)
  end

  def num_components(flags = BxDF::Type::All)
    0
  end

  def f(wo_world, wi_world, flags)
    Color::BLACK
  end

  def pdf(wo, wi, flags = BxDF::Type::All)
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
