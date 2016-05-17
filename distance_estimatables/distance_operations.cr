require "../distance_estimatable"

module DE
  class DistanceOperation < DistanceEstimatable
    property a : DistanceEstimatable
    property b : DistanceEstimatable

    def initialize(@a, @b)
    end

    def distance_estimate(pos)
      0.0
    end
  end

  class Union < DistanceOperation
    def distance_estimate(pos)
      min(@a.distance_estimate(pos), @b.distance_estimate(pos))
    end
  end

  class Subtraction < DistanceOperation
    def distance_estimate(pos)
      max(-@a.distance_estimate(pos), @b.distance_estimate(pos))
    end
  end

  class Intersection < DistanceOperation
    def distance_estimate(pos)
      max(@a.distance_estimate(pos), @b.distance_estimate(pos))
    end
  end
end
