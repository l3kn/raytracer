class LambertianReflection < BxDF
  def initialize(@color : Color)
    @type = BxDFType::Reflection | BxDFType::Diffuse
  end

  def f(wo : Vector, wi : Vector)
    @color * INV_PI
  end
end
