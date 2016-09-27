require "../material"
require "../texture"

module Phong
  class Material < ::Material
    property k_a : Color
    property k_d : Color
    property k_s : Color
    property texture : Texture
    property shininess : Float64

    def initialize(@k_a, @k_d, @k_s, @shininess, @texture)
    end

    def initialize(k_a : Float64, k_d : Float64, k_s : Float64, @shininess, @texture)
      @k_a = Color.new(k_a)
      @k_d = Color.new(k_d)
      @k_s = Color.new(k_s)
    end
  end
end

