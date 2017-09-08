struct BxDF::LambertianReflection < BxDF
  @type : Type # For some reason crystal 0.21.0 needs this

  def initialize(@color : Color)
    @type = Type::Reflection | Type::Diffuse
  end

  def f(wo : Vector, wi : Vector)
    @color * INV_PI
  end
end
