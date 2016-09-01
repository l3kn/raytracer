require "../distance_estimatable"
require "../vec3"

module DE
  class Repeat < DistanceEstimatable
    property object : DistanceEstimatable
    property mod : Vec3

    def initialize(@object, @mod)
    end

    def distance_estimate(pos)
      pos += @mod / 2
      new_pos = Vec3.new(@mod.x == 0.0 ? pos.x : (pos.x % @mod.x) - @mod.x / 2,
        @mod.y == 0.0 ? pos.y : (pos.y % @mod.y) - @mod.y / 2,
        @mod.z == 0.0 ? pos.z : (pos.z % @mod.z) - @mod.z / 2)

      @object.distance_estimate(new_pos)
    end
  end

  class Translate < DistanceEstimatable
    property object : DistanceEstimatable
    property offset : Vec3

    def initialize(@object, @offset)
    end

    def distance_estimate(pos)
      @object.distance_estimate(pos - @offset)
    end
  end

  class Scale < DistanceEstimatable
    property object : DistanceEstimatable
    property factor : Float64

    def initialize(@object, @factor)
    end

    def distance_estimate(pos)
      @object.distance_estimate(pos * @factor) / @factor
    end
  end

  class SwapXY < DistanceEstimatable
    property object : DistanceEstimatable

    def initialize(@object)
    end

    def distance_estimate(pos)
      @object.distance_estimate(Vec3.new(pos.y, pos.x, pos.z))
    end
  end

  class SwapXZ < DistanceEstimatable
    property object : DistanceEstimatable

    def initialize(@object)
    end

    def distance_estimate(pos)
      @object.distance_estimate(Vec3.new(pos.z, pos.y, pos.x))
    end
  end

  class SwapYZ < DistanceEstimatable
    property object : DistanceEstimatable

    def initialize(@object)
    end

    def distance_estimate(pos)
      @object.distance_estimate(Vec3.new(pos.x, pos.z, pos.y))
    end
  end
end
