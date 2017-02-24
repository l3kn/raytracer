struct LambertianReflection < BxDF
  @type : Int32 # For some reason crystal 0.21.0 needs this

  def initialize(@color : Color)
    @type = BxDFType::REFLECTION | BxDFType::DIFFUSE
  end

  def f(wo : Vector, wi : Vector)
    @color * INV_PI
  end
end
