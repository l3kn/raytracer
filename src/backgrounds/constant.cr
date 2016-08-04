require "../background"

class ConstantBackground < Background
  property color : Vec3

  def initialize(@color)
  end

  def get(ray)
    @color
  end
end
