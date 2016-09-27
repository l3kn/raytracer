require "../background"

class ConstantBackground < Background
  def initialize(@color : Color)
  end

  def get(ray)
    @color
  end
end
