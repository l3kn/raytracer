class LambertianReflection < BxDF
  def initialize(@color : Color)
    super(BxDFType::Reflection | BxDFType::Diffuse)
  end

  def f(wo : Vector, wi : Vector)
    @color / Math::PI
  end
end
