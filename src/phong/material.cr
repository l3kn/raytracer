require "../material"
require "../texture"

module Phong
  class Material < ::Material
    property k_a : Vec3
    property k_d : Vec3
    property k_s : Vec3
    property texture : Texture
    property shininess : Float64

    def initialize(@k_a, @k_d, @k_s, @shininess, @texture)
    end

    def initialize(k_a : Float64, k_d : Float64, k_s : Float64, @shininess, @texture)
      @k_a = Vec3.new(k_a)
      @k_d = Vec3.new(k_d)
      @k_s = Vec3.new(k_s)
    end
  end
end

