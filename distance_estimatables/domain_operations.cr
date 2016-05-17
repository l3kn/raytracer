require "../distance_estimatable"

module DE
  class Repeat < DistanceEstimatable
    property object : DistanceEstimatable
    property mod : Vec3

    def initialize(@object, @mod)
    end

    def distance_estimate(pos)
      new_pos = Vec3.new(@mod.x == 0.0 ? pos.x : (pos.x % @mod.x) - @mod.x / 2,
                         @mod.y == 0.0 ? pos.y : (pos.y % @mod.y) - @mod.y / 2,
                         @mod.z == 0.0 ? pos.z : (pos.z % @mod.z) - @mod.z / 2)
        
      @object.distance_estimate(new_pos)
    end
  end
end
