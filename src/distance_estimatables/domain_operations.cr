module DE
  class Repeat < DistanceEstimatable
    def initialize(@object : DistanceEstimatable, @mod : Vector); end

    def distance_estimate(pos)
      pos += @mod / 2.0
      new_pos = Point.new(
        @mod.x == 0.0 ? pos.x : (pos.x % @mod.x) - @mod.x / 2,
        @mod.y == 0.0 ? pos.y : (pos.y % @mod.y) - @mod.y / 2,
        @mod.z == 0.0 ? pos.z : (pos.z % @mod.z) - @mod.z / 2
      )

      @object.distance_estimate(new_pos)
    end
  end

  class Translate < DistanceEstimatable
    def initialize(@object : DistanceEstimatable, @offset : Vector); end

    def distance_estimate(pos)
      @object.distance_estimate(pos - @offset)
    end
  end

  class Scale < DistanceEstimatable
    def initialize(@object : DistanceEstimatable, @factor : Float64); end

    def distance_estimate(pos)
      @object.distance_estimate(pos * @factor) / @factor
    end
  end

  class SwapXY < DistanceEstimatable
    def initialize(@object : DistanceEstimatable); end
    def distance_estimate(pos); @object.distance_estimate(pos.yxz); end
  end

  class SwapXZ < DistanceEstimatable
    def initialize(@object : DistanceEstimatable); end
    def distance_estimate(pos); @object.distance_estimate(poz.zyx); end
  end

  class SwapYZ < DistanceEstimatable
    def initialize(@object : DistanceEstimatable); end
    def distance_estimate(pos); @object.distance_estimate(pos.xzy), end
  end
end
