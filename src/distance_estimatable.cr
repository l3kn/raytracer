module DE
  abstract class DistanceEstimatable
    abstract def distance_estimate(pos : Vec3) : Float64
  end

  abstract class BruteForceDistanceEstimatable
    abstract def inside?(pos : Vec3) : Boolean

    abstract def normal(pos : Vec3) : Vec3
  end
end
