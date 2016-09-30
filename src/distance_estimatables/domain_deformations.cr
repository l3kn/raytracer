require "../vector"
require "../distance_estimatable"

module DE
  class Twist < DistanceEstimatable
    property object : DistanceEstimatable

    def initialize(@object)
    end

    def distance_estimate(pos)
      c = Math.cos(0.5*pos.y)
      s = Math.sin(0.5*pos.y)

      new_pos = Point.new(
        c * pos.x - s * pos.z,
        s * pos.x + c * pos.z,
        pos.y
      )
      @object.distance_estimate(new_pos)
    end
  end
end
