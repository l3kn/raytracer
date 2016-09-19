module Phong
  class Light
    property position : Vec3
    property intensity : Float64

    def initialize(@position, @intensity)
    end
  end
end

