module Phong
  class Light
    property position : Point
    property intensity : Float64

    def initialize(@position, @intensity)
    end
  end
end

