module DE
  abstract class DistanceEstimatable
    abstract def distance_estimate(pos : Point) : Float64
  end

  abstract class BruteForceDistanceEstimatable
    abstract def inside?(pos : Point) : Boolean
    abstract def normal(pos : Point) : Vector
  end
end
