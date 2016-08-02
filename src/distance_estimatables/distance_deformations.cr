require "../distance_estimatable"

module DE
  class Blend < DistanceEstimatable
    property a : DistanceEstimatable
    property b : DistanceEstimatable

    def initialize(@a, @b, @k = 50.0)
    end

    def distance_estimate(pos)
      smin(@a.distance_estimate(pos), @b.distance_estimate(pos))
    end

    def smin(a, b)
      a = a ** @k
      b = b ** @k

      ((a*b)/(a+b)) ** (1.0 / @k)
    end
  end
end
